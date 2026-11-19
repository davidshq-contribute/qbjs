function _QB() {
    // mininimal console-only implementation of the qb.js runtime library
    // initially used only for the qbc.js command line compiler
    var _rndSeed;
    var _vfs = {
        tokenizePath: function(path) {
            path = path.replaceAll("\\","/");
            let parts = path.split("/");
            parts.isFullpath = false;
            if (path.indexOf("/") == 0) {
                parts.isFullpath = true;
            }
            if (parts[0].match(/[A-Z|a-z]:/)) {
                parts.shift();
                parts.isFullpath = true;
            }
            if (parts[0] == "") {
                while (parts.length > 0 && parts[0] == "") {
                    parts.shift();
                }
            }
            if (parts.isFullpath && parts.length == 0) {
                parts.isRoot = true;
            }
            else {
                parts.isRoot = false;
            }
            return parts;
        },
        getParentPath: function(path) {
            var parts = this.tokenizePath(path);
            var path = "";
            if (parts.length < 2) {
                if (parts.isFullpath) { return "/"; }
                else { return ""; }
            }
            for (var i=0; i < parts.length-1; i++) {
                path += "/" + parts[i];
            }
            return path;
        },
        getFileName: function(path) {
            var parts = this.tokenizePath(path);
            return parts[parts.length-1];
        }
    }

    // Runtime Assertions
    function _assertParam(param, arg) {
        if (arg == undefined) { arg = 1; }
        if (param == undefined) { throw new Error("Method argument " + arg + " is required"); }
    }

    function _assertNumber(param, arg) {
        if (arg == undefined) { arg = 1; }
        if (param && param.rgba && typeof param.rgba == "function") {
            param = QB.func_Val(param);
        }
        if (isNaN(param)) { throw new Error("Number required for method argument " + arg); }
        return param;
    }

    // Array handling methods
    // ----------------------------------------------------
    function initArray(dimensions, obj) {
        var a = {};
        if (dimensions && dimensions.length > 0) {
            a._dimensions = dimensions;
        }
        else {
            // default to single dimension to support Dim myArray() syntax
            // for convenient hashtable declaration
            a._dimensions = [{l:0,u:1}];
        }
        a._newObj = { value: obj };
        return a;
    };

    function resizeArray (a, dimensions, obj, preserve) {
       if (!preserve) {
            var props = Object.getOwnPropertyNames(a);
            for (var i = 0; i < props.length; i++) {
                if (props[i] != "_newObj") {
                    delete a[props[i]];
                }
            }
        }
        if (dimensions && dimensions.length > 0) {
            a._dimensions = dimensions;
        }
        else {
            // default to single dimension to support Dim myArray() syntax
            // for convenient hashtable declaration
            a._dimensions = [{l:0,u:1}];
        }
    }

    function arrayValue(a, indexes) {
        var value = a;
        for (var i=0; i < indexes.length; i++) {
            if (value[indexes[i]] == undefined) {
                if (i == indexes.length-1) {
                    value[indexes[i]] = JSON.parse(JSON.stringify(a._newObj));
                }
                else {
                    value[indexes[i]] = {};
                }
            }
            value = value[indexes[i]];
        }

        return value;
    }

    function halt() {
        /*_haltedFlag = true;
        _runningFlag = false;
        _inputMode = false;
        GX.soundStopAll();
        toggleCursor(true);*/
    }

    function halted() {
        return false;
        //return _haltedFlag;
    };

    function autoLimit() {
        /*var timeElapsed = new Date() - _lastLimitTime;
        if (timeElapsed > 1000) { 
            _flushAllScreenCache();
            await GX.sleep(1);
            _lastLimitTime = new Date();
        }*/
    }

    function func_Abs(value) {
        value = _assertNumber(value);
        return Math.abs(value);
    }

    function func_Asc(value, pos) {
        _assertParam(value);
        if (pos == undefined) {
            pos = 0;
        }
        else {
            pos = _assertNumber(pos, 2);
            pos--; 
        }

        var c = String(value).charCodeAt(pos);
        return c;
    }

    function func_Chr(charCode) {
        charCode = _assertNumber(charCode);
        return String.fromCharCode(charCode);
    }

    function func_Command() {
        return "";
    }

    // The characters of code page 437 for the bytes 128 to 255, as qb.js maps them for CHR$
    var _cp437High = [
        0x00C7, 0x00FC, 0x00E9, 0x00E2, 0x00E4, 0x00E0, 0x00E5, 0x00E7, 0x00EA, 0x00EB, 0x00E8, 0x00EF, 0x00EE, 0x00EC, 0x00C4, 0x00C5,
        0x00C9, 0x00E6, 0x00C6, 0x00F4, 0x00F6, 0x00F2, 0x00FB, 0x00F9, 0x00FF, 0x00D6, 0x00DC, 0x00A2, 0x00A3, 0x00A5, 0x20A7, 0x0192,
        0x00E1, 0x00ED, 0x00F3, 0x00FA, 0x00F1, 0x00D1, 0x00AA, 0x00BA, 0x00BF, 0x2310, 0x00AC, 0x00BD, 0x00BC, 0x00A1, 0x00AB, 0x00BB,
        0x2591, 0x2592, 0x2593, 0x2502, 0x2524, 0x2561, 0x2562, 0x2556, 0x2555, 0x2563, 0x2551, 0x2557, 0x255D, 0x255C, 0x255B, 0x2510,
        0x2514, 0x2534, 0x252C, 0x251C, 0x2500, 0x253C, 0x255E, 0x255F, 0x255A, 0x2554, 0x2569, 0x2566, 0x2560, 0x2550, 0x256C, 0x2567,
        0x2568, 0x2564, 0x2565, 0x2559, 0x2558, 0x2552, 0x2553, 0x256B, 0x256A, 0x2518, 0x250C, 0x2588, 0x2584, 0x258C, 0x2590, 0x2580,
        0x03B1, 0x00DF, 0x0393, 0x03C0, 0x03A3, 0x03C3, 0x00B5, 0x03C4, 0x03A6, 0x0398, 0x03A9, 0x03B4, 0x221E, 0x03C6, 0x03B5, 0x2229,
        0x2261, 0x00B1, 0x2265, 0x2264, 0x2320, 0x2321, 0x00F7, 0x2248, 0x00B0, 0x2219, 0x00B7, 0x221A, 0x207F, 0x00B2, 0x25A0, 0x00A0
    ];

    // Reads a source file. A file that is not valid UTF-8 was written for QB or QB64, whose editors save
    // code page 437, so its bytes are read as that: a box drawing character in a string literal then
    // prints as it does in QB64.
    function readSource(file) {
        const fs = require("fs");
        const bytes = fs.readFileSync(file);
        try {
            return new TextDecoder("utf-8", { fatal: true, ignoreBOM: true }).decode(bytes);
        }
        catch (e) {
            var text = "";
            for (var i=0; i < bytes.length; i++) {
                var b = bytes[i];
                text += String.fromCharCode(b < 128 ? b : _cp437High[b - 128]);
            }
            return text;
        }
    }

    async function sub_Fetch (url, fetchRes) {
        const path = require("path");
        try {
            // attempt to find file in local project directory
            const data = readSource(url);
            fetchRes.ok = true;
            fetchRes.status = 200;
            fetchRes.text = data;
        }
        catch (e) {
            try {
                // look for the file in the standard lib location
                const data = readSource(__dirname + path.sep + url);
                fetchRes.ok = true;
                fetchRes.status = 200;
                fetchRes.text = data;
            }
            catch (e2) {
                try {
                    // try to load from url
                    var response = await fetch(url);
                    var responseText = await(response.text());
                    fetchRes.ok = response.ok;
                    fetchRes.status = response.status;
                    fetchRes.statusText = response.statusText;
                    fetchRes.text = responseText;
                }
                catch (e3) {}
            }
        }
    }

    async function func_Fetch(url) {
        var fetchRes = {};
        await QB.sub_Fetch(url, fetchRes);
        return fetchRes;
    }

    function func_Left(value, n) {
        _assertParam(value, 1);
        n = _assertNumber(n, 2);
        return String(value).substring(0, n);
    }

    function func_InStr(arg1, arg2, arg3) {
        _assertParam(arg1, 1);
        _assertParam(arg2, 2);
        var startIndex = 0;
        var strSource = "";
        var strSearch = "";
        if (arg3 != undefined) {
            startIndex = arg1-1;
            strSource = String(arg2);
            strSearch = String(arg3);
        }
        else {
            strSource = String(arg1);
            strSearch = String(arg2);
        }
        return strSource.indexOf(strSearch, startIndex)+1;
    }

    function func__InStrRev(arg1, arg2, arg3) {
        _assertParam(arg1, 1);
        _assertParam(arg2, 2);
        var startIndex = +Infinity;
        var strSource = "";
        var strSearch = "";
        if (arg3 != undefined) {
            startIndex = arg1-1;
            strSource = String(arg2);
            strSearch = String(arg3);
        }
        else {
            strSource = String(arg1);
            strSearch = String(arg2);
        }
        return strSource.lastIndexOf(strSearch, startIndex)+1;
    }
    
    function func_LCase(value) {
        _assertParam(value);
        return String(value).toLowerCase();
    };

    function func_Left(value, n) {
        _assertParam(value, 1);
        n = _assertNumber(n, 2);
        return String(value).substring(0, n);
    }

    function func_Len(value) {
        _assertParam(value);
        return String(value).length;
    }

    function func_LTrim(value) {
        _assertParam(value);
        return String(value).trimStart();
    }

    function func_Mid(value, n, len) {
        _assertParam(value, 1);
        n = _assertNumber(n, 2);
        if (len == undefined) {
            return String(value).substring(n-1);
        }
        else {
            return String(value).substring(n-1, n+len-1);
        }
    }
 
    function func_Right(value, n) {
        _assertParam(value, 1);
        n = _assertNumber(n, 2);
        if (value == undefined) {
            return "";
        }
        var s = String(value);
        return s.substring(s.length-n, s.length);
    }

    function func__Round(value) {
        value = _assertNumber(value);
        if (value < 0) {
            return -Math.round(-value);
        } else {
            return Math.round(value);
        }
    }

    // NOT of a group in the compiler's own code: a comparison is a boolean, which gives 0 or -1
    function not(value) {
        if (typeof value == "boolean") {
            return value ? 0 : -1;
        }
        return ~value;
    }

    // integer assignment and integer parameters: the compiler's own code only needs QBJS's default rounding
    function roundInt(value) {
        if (typeof value == "boolean") {
            return value ? -1 : 0;
        }
        return Math.round(value);
    }

    function func_Rnd(n) {
        if (n == undefined) {n = 1;}
        if (n != 0) {
            if (n < 0) {
                const buffer = new ArrayBuffer(8);
                const view = new DataView(buffer);  
                view.setFloat32(0, n, false);
                var m = view.getUint32(0);
                _rndSeed = (m & 0xFFFFFF) + ((m & 0xFF000000) >>> 24);
            }
            _rndSeed = (_rndSeed * 16598013 + 12820163) & 0xFFFFFF;
        }
        return _rndSeed / 0x1000000;
    }

    function func_RTrim(value) {
        _assertParam(value);
        return String(value).trimEnd();
    }

    function func_Str(value) {
        return String(value);
    }

    function func_String(ccount, s) {
        ccount = _assertNumber(ccount, 1);
        _assertParam(s, 2);
        if (typeof s === "string") {
            s = s.substring(0, 1);
        }
        else {
            s = String.fromCharCode(s);
        }
        return "".padStart(ccount, s);
    }

    function func__Trim(value) {
        _assertParam(value);
        return value.trim();
    }

    function func_UBound(a, dimension) {
        _assertParam(a);
        if (dimension == undefined) {
            dimension = 1;
        }
        else {
            dimension = _assertNumber(dimension, 2);
        }
        return a._dimensions[dimension-1].u;
    }

    function func_UCase(value) {
        _assertParam(value);
        return String(value).toUpperCase();
    }

    return {
        initArray: initArray,
        resizeArray: resizeArray,
        arrayValue: arrayValue,
        autoLimit: autoLimit,
        halt: halt,
        halted: halted,
        vfs: function() { return _vfs; },
        func_Abs: func_Abs,
        func_Asc: func_Asc,
        func_Chr: func_Chr,
        func_Command: func_Command,
        func_Fetch: func_Fetch,
        sub_Fetch: sub_Fetch,
        func_InStr: func_InStr,
        func__InStrRev: func__InStrRev,
        func_LCase: func_LCase,
        func_Left: func_Left,
        func_Len: func_Len,
        func_LTrim: func_LTrim,
        func_Mid: func_Mid,
        func_Right: func_Right,
        func__Round: func__Round,
        not: not,
        readSource: readSource,
        roundInt: roundInt,
        roundLong: roundInt,
        func_Rnd: func_Rnd,
        func_RTrim: func_RTrim,
        func_Str: func_Str,
        func_String: func_String,
        func__Trim: func__Trim,
        func_UBound: func_UBound,
        func_UCase: func_UCase
    };
}

module.exports.QB = _QB;