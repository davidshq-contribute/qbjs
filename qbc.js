compile();

async function compile(src) {
    const qbc = await require("./qb2js.js").QBCompiler();
    const fs = require("fs");

    const sourceFile = process.argv[2];
    const data = require("./qb-console.js").QB().readSource(sourceFile);

    var result = "";
    if (sourceFile.endsWith("qb2js.bas")) {
        qbc.setSelfConvert();
        result = await qbc.compile(data);
    }
    else {
        if (process.argv.includes("--round-half-even")) {
            qbc.setRoundHalfEven();
        }
        if (process.argv.includes("--byref")) {
            qbc.setByRef();
        }
        if (process.argv.includes("--qb-booleans")) {
            qbc.setQBBooleans();
        }
        if (process.argv.includes("--qb-lines")) {
            qbc.setQBLines();
        }
        if (process.argv.includes("--qb-sound")) {
            qbc.setQBSound();
        }
        result = "async function __qbjs_run() {\n" + await qbc.compile(data) + "\n}";
    }
    fs.writeFileSync(process.argv[3], result, "utf8");
    
    var warnings = qbc.getWarnings();
    for (var i=0; i < warnings.length; i++) {
        var mtype = warnings[i].mtype ? "ERROR" : "WARN";
        console.log(mtype + ":" + warnings[i].line + ":" + warnings[i].text);
    }
}