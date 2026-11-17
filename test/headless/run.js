// Runs QBJS's unit tests (test/all-tests.bas: the QB tests and the library tests) in a headless
// Chrome and prints what the page logs.
//
//   cd test/headless
//   npm install
//   node run.js [--entry <test file>] [--chrome <path>] [--timeout <seconds>]
//
// --entry is a file under test/ (default all-tests.bas; qb-all-tests.bas runs only the QB tests).
// The QBJS folder this file is in is served as it is, on 127.0.0.1, and its page runs the entry file
// in auto mode. QBJS asks for an imported test module, such as ./io/fs.bas, at the top of the site,
// so a .bas path that is not there is answered with the one file under test/ whose path ends with it.
//
// Each test module logs "... tests completed with no errors" when all its checks pass; a failed check
// stops the run with an error such as "7 <> 2". "TypeError: testMethod is not a function" is logged
// by a test of AssertError and is expected. Exit code: 0 when every test module that the entry file
// imports completed and the page reported no error, 1 when not, 2 when the run could not start.
const fs = require("fs");
const http = require("http");
const path = require("path");
const puppeteer = require("puppeteer-core");

const QBJS = path.resolve(__dirname, "..", "..");

function options(argv) {
    var o = { entry: "all-tests.bas", chrome: undefined, timeout: 90 };
    for (var i = 0; i < argv.length; i++) {
        if (argv[i] == "--entry") { o.entry = argv[++i]; }
        else if (argv[i] == "--chrome") { o.chrome = argv[++i]; }
        else if (argv[i] == "--timeout") { o.timeout = Number(argv[++i]); }
        else { console.error("unknown option " + argv[i]); process.exit(2); }
    }
    return o;
}

function findChrome(given) {
    var places = [given, process.env.CHROME_PATH,
        "C:/Program Files/Google/Chrome/Application/chrome.exe",
        "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe",
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        "/usr/bin/google-chrome", "/usr/bin/chromium", "/usr/bin/chromium-browser"];
    return places.find(p => p && fs.existsSync(p));
}

// Every .bas file under test/, as paths relative to the QBJS folder with forward slashes.
function testFiles() {
    var list = [];
    var walk = dir => {
        for (var e of fs.readdirSync(path.join(QBJS, dir), { withFileTypes: true })) {
            if (e.name == "headless") { continue; }
            var rel = dir + "/" + e.name;
            if (e.isDirectory()) { walk(rel); }
            else if (rel.endsWith(".bas")) { list.push(rel); }
        }
    };
    walk("test");
    return list;
}

// The file a .bas path names: the path itself, else the one test file whose path ends with it.
function resolveBas(rel) {
    rel = rel.replace(/^(\.\/)+/, "");
    if (fs.existsSync(path.join(QBJS, rel))) { return path.join(QBJS, rel); }
    var found = testFiles().filter(f => f.endsWith("/" + rel));
    return found.length == 1 ? path.join(QBJS, found[0]) : null;
}

// The test modules that a test file imports, directly or through other test files: the files that
// log "tests completed". The libraries the tests use (lib/...) are not test modules.
function testModules(file, seen) {
    if (seen.has(file)) { return 0; }
    seen.add(file);
    var text = fs.readFileSync(file, "utf8");
    var count = text.includes("tests completed") ? 1 : 0;
    var imports = text.matchAll(/^\s*Import\s+\w+\s+From\s+"([^"]+)"/gim);
    for (var m of imports) {
        if (m[1].startsWith("lib/")) { continue; }
        var target = resolveBas(m[1]);
        if (target) { count += testModules(target, seen); }
    }
    return count;
}

function serve(root) {
    var types = { ".html": "text/html", ".js": "text/javascript", ".png": "image/png", ".css": "text/css" };
    var server = http.createServer((req, res) => {
        var rel = decodeURIComponent(req.url.split("?")[0]).replace(/^\//, "") || "index.html";
        var file = path.join(root, rel);
        if (!fs.existsSync(file) && rel.endsWith(".bas")) { file = resolveBas(rel) || file; }
        if (!file.startsWith(root) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
            res.writeHead(404);
            res.end();
            return;
        }
        res.writeHead(200, { "Content-Type": types[path.extname(file).toLowerCase()] || "application/octet-stream" });
        fs.createReadStream(file).pipe(res);
    });
    return new Promise(resolve => server.listen(0, "127.0.0.1", () => resolve(server)));
}

async function main() {
    var o = options(process.argv.slice(2));
    var chrome = findChrome(o.chrome);
    if (!chrome) {
        console.error("Chrome was not found; give its path with --chrome or CHROME_PATH");
        process.exit(2);
    }
    var modules = testModules(path.join(QBJS, "test", o.entry), new Set());

    var server = await serve(QBJS);
    var browser = await puppeteer.launch({ executablePath: chrome, headless: true });
    var origin = "http://127.0.0.1:" + server.address().port;
    // the string tests use the clipboard, which headless Chrome refuses without these
    await browser.defaultBrowserContext().overridePermissions(origin,
        ["clipboard-read", "clipboard-write", "clipboard-sanitized-write"]);
    var page = await browser.newPage();
    var lines = [];
    var failed = false;
    page.on("console", m => {
        var text = m.text();
        if (text.startsWith("Manifest:") || text.includes("willReadFrequently")) { return; }
        // a request for a file the server does not have is not a failure: some tests look for a file
        // on the server (lib/compatibility/qb64pe.bas asks for test.txt), and a check that fails stops the
        // run before its module logs "tests completed"
        if (m.type() == "error" && !text.startsWith("Failed to load resource")) { failed = true; }
        lines.push("[" + m.type() + "] " + text);
    });
    page.on("pageerror", e => { failed = true; lines.push("[page error] " + e.message); });
    page.on("response", r => { if (r.status() >= 400) { lines.push("[http " + r.status() + "] " + r.url()); } });

    // auto mode runs the program as soon as it is loaded
    await page.goto(origin + "/index.html?mode=auto&src=test/" + o.entry);
    var completed = () => lines.filter(l => l.includes("tests completed")).length;
    var start = Date.now();
    while (Date.now() - start < o.timeout * 1000 && completed() < modules && !failed) {
        await new Promise(r => setTimeout(r, 500));
    }
    await new Promise(r => setTimeout(r, 1000));
    await browser.close();
    server.close();

    console.log(lines.join("\n"));
    var ok = completed() == modules && !failed;
    console.log((ok ? "PASS" : "FAIL") + ": " + completed() + " of " + modules + " test modules completed");
    process.exit(ok ? 0 : 1);
}

main().catch(e => { console.error(e); process.exit(2); });
