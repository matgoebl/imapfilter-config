lu = require('luaunit')

require("imapfilterlib")

TesteMailExtraction = {}
    function TesteMailExtraction:testPlain()
        lu.assertEquals(extract_email("test@example.org"),"test@example.org")
    end

    function TesteMailExtraction:testWhitespace()
        lu.assertEquals(extract_email(" test@example.org "),"test@example.org")
    end

    function TesteMailExtraction:testAngleBrackets()
        lu.assertEquals(extract_email("test@example.org (Test)"),"test@example.org")
    end

    function TesteMailExtraction:testRoundBrackets()
        lu.assertEquals(extract_email('"Test" <test@example.org>'),"test@example.org")
    end

os.exit( lu.LuaUnit.run() )
