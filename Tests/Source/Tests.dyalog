:Namespace Test
    (⎕IO ⎕ML ⎕WX)←1 1 3

    where←⍕⎕THIS
    base_dir ←'.\Tests\Builds\'

    ∇ Test_All;fns
      fns←{⍵/⍨⌽~∧\' '∊⍨⌽⍵}¨↓⎕NL 3
      ⍎¨⎕SI~⍨fns/⍨(4↑¨fns)∊⊂'Test'
    ∇

    :Section ExeTesting
    ∇ App1
      Form_WC
      ⎕OFF
    ∇

    ∇ Form_WC;test
      'test'⎕WC'Form' 'Test .EXE'('Size'(10 20))
      ⎕DQ'test'
    ∇

    ∇ App2
      Form_HTMLRenderer
      ⎕OFF
    ∇

    ∇ Form_HTMLRenderer;head;body
      head←'<head><title>.EXT Test</title></head>'
      body←'<body> .EXE TEST SPACE </body>'
      'test'⎕WC'HTMLRenderer'(head,body)('Size'(10 20))
      ⎕DQ'test'
    ∇

    ∇ success←Test_EXE_001;APP1;name;success
      :Access Public
      ⍝ Bare min StandaloneNativeExe 0 arg constuctor
      name←⊃⎕SI
      :With APP1←⎕NEW ##.BuildTool
          SuppressOutput←1
          BaseDir←##.base_dir
          ExportName←name
          ExportType←'StandaloneNativeExe'
          Flags←8
          LX←##.where,'.App1'
          success←Run
      :EndWith
    ∇

    ∇ success←Test_EXE_002;APP1;name
    ⍝ Bare min StandaloneNativeExe 1 arg constuctor
      name←⊃⎕SI
      :With APP1←⎕NEW ##.BuildTool name
          SuppressOutput←1
          ExportType←'StandaloneNativeExe'
          BaseDir←##.base_dir
          Flags←8
          LX←##.where,'.App1'
          success←Run
      :EndWith
    ∇

    ∇ success←Test_EXE_003;APP1;name
      name←⊃⎕SI
    ⍝ Bare min StandaloneNativeExe 2 arg constuctor
      :With APP1←⎕NEW ##.BuildTool(name'StandaloneNativeExe')
          SuppressOutput←1
          BaseDir←##.base_dir
          Flags←8
          LX←##.where,'.App1'
          success←Run
      :EndWith
    ∇

    ∇ success←Test_EXE_004;APP1;name
      name←⊃⎕SI
    ⍝ Bare min StandaloneNativeExe 3 arg constuctor
      :With APP1←⎕NEW ##.BuildTool('App1_Test4' 'StandaloneNativeExe'base_dir)
          SuppressOutput←1
          Flags←8
          LX←##.where,'.App1'
          success←Run
      :EndWith
    ∇

    ∇ success←Test_EXE_005;APP1;name
      name←⊃⎕SI
    ⍝ Bare min NativeExe - test addition of Dyalog file
      :With APP1←⎕NEW ##.BuildTool name
          SuppressOutput←1
          ExportType←'NativeExe'
          BaseDir←##.base_dir
          Flags←8
          LX←##.where,'.App1'
          AddDyalogFiles←'dyalog160rt_unicode.dll'
          success←Run
      :EndWith
    ∇
    ∇ success←Test_EXE_006;APP1;name
      name←⊃⎕SI
     ⍝ Bare min NativeExe - test addition of multiple Dyalog files
      :With APP1←⎕NEW ##.BuildTool name
          SuppressOutput←1
          ExportType←'NativeExe'
          BaseDir←##.base_dir
          Flags←8
          LX←##.where,'.App2'
          AddDyalogFiles←'chrome_elf.dll' 'dyalog160rt_unicode.dll' 'http.dll' 'HttpInterceptor.dll'
          success←Run
      :EndWith
    ∇

    ∇ success←Test_EXE_007;APP1;name
      name←⊃⎕SI
    ⍝ StandaloneNativeEx: Test changin MaxWS with numeric
      :With APP1←⎕NEW ##.BuildTool name
          SuppressOutput←1
          ExportType←'StandaloneNativeExe'
          BaseDir←##.base_dir
          Flags←8
          LX←##.where,'.App2'
          AddDyalogFiles←'chrome_elf.dll'
          MaxWS←1000
          success←Run
      :EndWith
    ∇

    ∇ success←Test_EXE_008;APP1;name
      name←⊃⎕SI
    ⍝ StandaloneNativeEx: Test changin MaxWS with string
    ⍝                       and not making a copy of the WS
      :With APP1←⎕NEW ##.BuildTool name
          SuppressOutput←1
          ExportType←'StandaloneNativeExe'
          BaseDir←##.base_dir
          Flags←8
          LX←##.where,'.App2'
          AddDyalogFiles←'chrome_elf.dll'
          MaxWS←'1G'
          MakeCopyOfCurrentWS←0
          success←Run
      :EndWith
    ∇

    ∇ success←Test_EXE_009;APP1;name
      name←⊃⎕SI
      ⍝ StandaloneNativeEx: Test adding an icon file
      :With APP1←⎕NEW ##.BuildTool name
          SuppressOutput←1
          ExportType←'StandaloneNativeExe'
          BaseDir←##.base_dir
          Flags←8
          LX←##.where,'.App2'
          AddDyalogFiles←'chrome_elf.dll'
          MaxWS←'1G'
          MakeCopyOfCurrentWS←0
          IconFile←'.\Tests\aplapple.ico'
          success←Run
      :EndWith
    ∇

    ∇ success←Test_EXE_010;APP1;name
      ⍝ StandaloneNativeEx: Test adding non Dyalog files:
      ⍝                           - single file
      ⍝                           - multiple files
      ⍝                           - to the defulat dir
      ⍝                           - to a dir that doesn't exist yet
      ⍝                           - to a dir that already exists
      name←⊃⎕SI
      :With APP1←⎕NEW ##.BuildTool name
          SuppressOutput←1
          ExportType←'StandaloneNativeExe'
          BaseDir←##.base_dir
          Flags←40  ⍝ Runtime + XP Look and Feel
          LX←##.where,'.App2'
          AddDyalogFiles←'chrome_elf.dll'
          MaxWS←'1G'
          MakeCopyOfCurrentWS←0
          IconFile←'.\Tests\aplapple.ico'
          AddFiles'.\Tests\config.ini'
          '/js/'AddFiles'.\Tests\data.json' '.\Tests\chart.js'
          '/js/'AddFiles'.\Tests\script.js'
          '/ico/'AddFiles'.\Tests\aplapple.ico'
          success←Run
      :EndWith
    ∇

    ∇ success←Test_EXE_011;APP1;name
    ⍝ Bare test compile
      name←⊃⎕SI
      :With APP1←⎕NEW ##.BuildTool name
          SuppressOutput←1
          ExportType←'StandaloneNativeExe'
          BaseDir←##.base_dir
          Flags←8
          LX←##.where,'.App1'
          Compile←1
          success←Run
      :EndWith
    ∇

    :EndSection

    :Section DllTesting
    ∇ r←Iota int
      :Access Public
      r←int
    ∇

    ∇ r←Rho vec
      :Access Public
      r←⍴vec
    ∇

    ∇ success←Test_DLL_001;DLL;name;⎕USING;DYALOG;using
      name←⊃⎕SI
    ⍝ Test .NET .dll
      :With DLL←⎕NEW ##.BuildTool name
          SuppressOutput←1
          ExportType←'Library'
          BaseDir←##.base_dir
          Flags←8
          success←Run
      :EndWith     
      using←⊃,/  DLL.(ExportDir ExportName)
      ⎕USING←using

    ∇
    ∇ success←Test_DLL_002;DLL;name;⎕USING;DYALOG
      name←⊃⎕SI
    ⍝ Test In Process Server .dll
      :With DLL←⎕NEW ##.BuildTool name
          SuppressOutput←1
          ExportType←'InProcessServer'
          BaseDir←##.base_dir
          Flags←8
          success←Run
      :EndWith
    ∇
    :EndSection
:EndNamespace
