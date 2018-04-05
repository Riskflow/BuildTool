:Class BuildTool
⍝ ## This is a utility class that allows you to automating the exporting process of your
⍝ Dyalog applications.
⍝
    :Field Public Shared export_types ← 'ActiveXControl' 'InProcessServer' 'Library' 'NativeExe' 'OutOfProcessServer' 'StandaloneNativeExe'
    :Field Private icon_file          ← ''
    :Field Private cmd_line           ← ''
    :Field Private resource           ← ''
    :Field Private max_ws             ← ⍬
    :Field Private export_dir
    :Field Private base_dir           ← './'
    :Field Private add_files          ← ''
    :Field Private to_dir             ← ''
    :Field Private dyalog_files       ← ''
    :Field Private log                ← ''
    :Field Private export_name
    :Field Private export_type
    :Field Private flags              ← 8
    :Field Private lx
    :Field Private dyalog_dir
    :Field Private compile            ← 0       ⍝ compile all functions before building the export
    :Field Private save_ws            ← 1       ⍝ add a copy of the work space to the build
    :Field Private suppress_output    ← 0


    ∇ r←Version
      :Access Public Shared
      ⍝ Changes since previouse versions:
      ⍝ 1.0.1
      ⍝     * Reset ⎕LX is move before AddAddionalFiles
      ⍝       so that when a copy of the ws is saved it
      ⍝       is saved without the ⎕LX
      r←({⍵/⍨⌽~∨\⌽⍵∊'.'}⍕⎕THIS)'1.0.1' '2018-04-05'
    ∇

    ∇ make0
      :Access Public
      :Implements Constructor
      ⍝ Do nothing
    ∇
    ∇ make1 name
      :Access Public
      :Implements Constructor
      ⍝ Define the name of the export file on creation of instance.
      ExportName←name
    ∇
    ∇ make2(name type)
      :Access Public
      :Implements Constructor
      ⍝ Define the name of the export file and the type of export on creation of instance.
      ExportName←name
      ExportType←type
    ∇
    ∇ make3(name type dir)
      :Access Public
      :Implements Constructor
      ⍝ Define the name of the export file, the type of export and the export directory on creation of instance.
      ExportName←name
      ExportType←type
      BaseDir←dir
    ∇
⍝ PUBLIC PROPERTIES
    :Property AddDyalogFiles
    :Access Public
    ⍝ OPTIONAL\
    ⍝ List the required dyalog files for the running of the export.
    ⍝ Just the file should be listed (with extention). The directory
    ⍝ is calculated dynamically.
    ⍝ ~~~
    ⍝ AddDyalogFiles←'dyalog160rt_unicode.dll'
    ⍝ AddDyalogFiles←'dyalog160rt_unicode.dll' 'dyalognet.dll'
    ⍝ ~~~
        ∇ set files
          GetDyalogDir
          dyalog_files←CheckFilesAndDirs dyalog_dir∘,¨,⊆files.NewValue
        ∇
    :EndProperty
    :Property CmdLine
    :Access Public
    ⍝ OPTIONAL\
    ⍝ Is the command line that is bound in the find and passed to dyalog.dll
    ⍝ when the dll is started.
        ∇ set cmd_line_statement
          cmd_line←cmd_line_statement.NewValue
        ∇
    :EndProperty
    :Property BaseDir
    :Access Public
    ⍝ REQUIRED\
    ⍝ Must be set to the location of the directory inwhich the export will be stored.
        ∇ set dir
          base_dir←CheckFilesAndDirs dir.NewValue
        ∇
    :EndProperty
    :Property ExportDir
    :Access Public
    ⍝ AVALIBLE POST RUN\
    ⍝ Returns the full directory path inwhich the full export has been stored.
        ∇ r←get
          r←export_dir
        ∇
    :EndProperty
    :Property Log
    :Access Public
    ⍝ AVALIBLE POST RUN\
    ⍝ Returns the full log that was generated during the build.
        ∇ r←get
          r←log
        ∇
    :EndProperty
    :Property ExportName
    :Access Public
    ⍝ REQUIRED\
    ⍝ Is the name of the export file. The extention should not be
    ⍝ included as it is picked up programatically.
        ∇ set name
          export_name←CheckName name.NewValue
        ∇
        ∇ r←get
          r←export_name,file_extention
        ∇
    :EndProperty
    :Property ExportType
    :Access Public
    ⍝ REQUIRED\
    ⍝ The export type must be one of the following:
    ⍝   * ActiveXControl
    ⍝   * InProcessServer
    ⍝   * Library
    ⍝   * NativeExe
    ⍝   * OutOfProcessServer
    ⍝   * StandaloneNativeExe
        ∇ set type_prop;type
          type←type_prop.NewValue
          :If export_types∊⍨⊂type
              export_type←type
          :Else
              'invalid export type'⎕SIGNAL 11
          :EndIf
        ∇
    :EndProperty
    :Property Flags
    :Access Public
    ⍝ REQUIRED\
    ⍝ The flag must be a sum of zero or more of the following values:
    ⍝   * BOUND_CONSOLE       2
    ⍝   * BOUND_USEDOTNET     4
    ⍝   * BOUND_RUNTIME       8
    ⍝   * BOUND_XPLOOK        32\
    ⍝                           \
    ⍝ EG: `Flags ← 40` would give an export that is both Runtime and XPLook
        ∇ set flag_prop;options;validflags;flag
          flag←flag_prop.NewValue
          options←0 2 4 8 32
          validflags←{⍵[⍋⍵]}∪+/∘∪¨⊃5{(,/∘⊃⍣(¯1+⍺))(↓⍣⍺)⍵((∘.,)⍣⍺)⍵}options
          :If flag∊validflags
              flags←flag
          :Else
              'invalid flag'⎕SIGNAL signal_start_range
          :EndIf
        ∇
    :EndProperty
    :Property IconFile
    :Access Public
    ⍝ REQUIRED\
    ⍝ If the export is a OutOfProcessServer or an .exe then this poperty can be optionally
    ⍝ set to the path pointing to a file which will be used as the icon for the export.\
    ⍝ The extention must be included.
        ∇ set file
          icon_file←CheckFilesAndDirs file.NewValue
        ∇
    :EndProperty
    :Property LX
    ⍝ CONDITIONALLY REQUIRED\
    ⍝ If the export is an .exe this must be set to the name of the function
    ⍝ to be assinged to ⎕LX.
    :Access Public
        ∇ set fn;foo
          :If 3=⎕NC foo←fn.NewValue
              lx←foo
          :Else
              ('could not find ',foo)⎕SIGNAL 2
          :EndIf
        ∇
    :EndProperty
    :Property MaxWS
    :Access Public
    ⍝ OPTIONAL\
    ⍝ Set to the maxium amount of memory the export will be allowed before thowing a
    ⍝ `WS FULL` error.  \
    ⍝ Input can be charater or numeric. If numeric then the number defults to kilibytes.
    ⍝ Otherwise if it is charater the units must be defined:
    ⍝   * K for kilobytes
    ⍝   * M for megabytes
    ⍝   * G for gigebytes
    ⍝   * T for terabytes
    ⍝   * P for petabytes
    ⍝   * E for exabytes\
    ⍝                   \
    ⍝ EG:               \
    ⍝ `MaxWS ← '1G'`    \
    ⍝ `MaxWS ← 256`     \
        ∇ set size
          max_ws←size.NewValue
        ∇
    :EndProperty
    :Property Resource
    :Access Public
    ⍝ OPTIONAL\
    ⍝ Is set to a filename the contents of which will be inserted
    ⍝ as a resource in the bound file (used by ASP.NET)
        ∇ set arg
          resource←arg.NewValue
        ∇
    :EndProperty
    ⍝ BOOLEAN INDICATORS
    :Property Compile
    :Access Public
    ⍝ OPTIONAL\
    ⍝ This will determine whether or not to complile all functions using
    ⍝ `2(400⌶)` before creating export. Defaults to 0.
        ∇ set boo
          compile←boo.NewValue
        ∇
    :EndProperty
    :Property MakeCopyOfCurrentWS
    :Access Public
    ⍝ OPTIONAL\
    ⍝ This indicator will determine whether or not to save a copy
    ⍝ of the WS at the time of the build. Defaults to 1.
        ∇ set boo
          save_ws←boo.NewValue
        ∇
    :EndProperty
    :Property SuppressOutput
    :Access Public
    ⍝ OPTIONAL\
    ⍝ Indicates whether or not to suppress the output from the build.
    ⍝ The export process is recorded in a log and by defult the log
    ⍝ if ouputed as it is recored. If `SuppressOutput` is set to 0
    ⍝ the output wil be suppressed.
        ∇ set arg
          suppress_output←arg.NewValue
        ∇
    :EndProperty
 ⍝ PRIVATE PROPERTIES
    :Property file_extention
        ∇ r←get
          :Select export_type
          :Case 'ActiveXControl' ⋄ r←'.ocx'
          :Case 'InProcessServer' ⋄ r←'.dll'
          :Case 'Library' ⋄ r←'.dll'
          :Case 'NativeExe' ⋄ r←'.exe'
          :Case 'OutOfProcessServer' ⋄ r←''
          :Case 'StandaloneNativeExe' ⋄ r←'.exe'
          :Else ⋄ 'invalid export type'⎕SIGNAL 602
          :EndSelect
        ∇
    :EndProperty
  ⍝ PUBLIC METHODS
    ∇ {r}←{to}AddFiles files
      ⍝ OPTIONAL\
      ⍝ Copies file(s) specified in the right arg to a directory specified by
      ⍝ the left arg.\
      ⍝ If the left arg does not yet exist it will be created. And if the left
      ⍝ arg is ommitted then the assumed directory is the same as the export
      ⍝ directory.
      :Access Public
      :If 0=⎕NC'to'
          to←''
      :EndIf
      add_files,←⊂CheckFilesAndDirs¨⊆files
      to_dir,←⊂RepBSl to
    ∇

    ∇ {success}←Run;build_dir;path;export_path;rsp;tmp;resp;time;cmd
      :Access Public
      ⍝ Function performs a build based of the paramters previousely set.
      ⍝ Returns boolean indicator of success as a shy result.
      :Trap 0
          LogBuild'build started at: ',FmtTS ⎕TS
          CreateBuildDir
          SetLX
          DoCompile
          CreateExport
          ResetLX
          AddAdditionalFiles
          LogBuild'build complete ',FmtTS ⎕TS
          success←1
      :Else
          HandleError
          success←0
      :EndTrap
    ∇
  ⍝ PRIVATE METHODS
    :Section Processing

    ∇ AddAdditionalFiles;rsp;dirs
      :If dyalog_files≢''
          rsp←export_dir∘CopyFiles¨dyalog_files
          LogBuild'copied: ',CommaAndList rsp/{,/1↓⎕NPARTS ⍵}¨dyalog_files
          LogBuild'to: ',export_dir
      :EndIf
      :If add_files≢''
          dirs←export_dir∘{⍺,⍵↓⍨'/'∊1↑⍵}¨to_dir
          rsp←3∘⎕MKDIR¨dirs
          :If ∨/rsp              ⍝ if any directories were created
              LogBuild¨'created: '∘,¨rsp/to_dir
          :EndIf
          rsp←dirs(CopyFiles{⍺∘⍺⍺¨⍵})¨add_files
          LogBuild¨⊃,/dirs{('copied: '∘,¨⍵),(⊂'to: ',⍺)}¨add_files
      :EndIf
      :If save_ws ⍝ Save a copy of the WS into the export directory
          0 ⎕SAVE export_dir,export_name,'.dws'
          LogBuild'copy of WS saved as: ',export_dir,export_name,'.dws'
      :EndIf
    ∇

    ∇ DoCompile;resp;old;new;total
      :If compile
          new old total←CompileAll
          LogBuild(⍕new),' fns compiled'
          LogBuild(⍕old),' fns already complied'
          LogBuild(⍕new+old),' fns compiled out of a total ',⍕total
      :EndIf
    ∇

    ∇ cmd←SetCmdLine
      :If max_ws≡⍬
          cmd←cmd_line
          LogBuild'MAXWS=DEFAULT'
      :Else
          cmd←export_name,file_extention,' MAXWS=',(⍕max_ws),' ',cmd_line
          LogBuild'MAXWS=',⍕max_ws
      :EndIf
      :If cmd_line≢''
          LogBuild'CMDLINE=',cmd
      :EndIf
    ∇

    ∇ CreateExport;cmd;rsp
      cmd←SetCmdLine
      export_path←export_dir,export_name,file_extention
      rsp←2 ⎕NQ'.' 'Bind'export_path export_type flags resource icon_file cmd
      LogBuild'created: ',export_path
    ∇

    ∇ CreateBuildDir;build_dir;rsp
      export_dir←RepBSl base_dir,export_name,' ',('--_---'FmtTS ⎕TS),'/'
      rsp←⎕MKDIR export_dir
      :If rsp
          LogBuild'created: ',export_dir
      :Else
          'build directory already exists'⎕SIGNAL 11
      :EndIf
    ∇

    ∇ SetLX
      :If '.exe'≡file_extention
          tmp_lx←⍕⎕LX   ⍝ store a temp copy so that there isn't a global overide of ⎕LX
          ⎕LX←lx
          LogBuild'⎕LX set to ',lx
      :EndIf
    ∇

    ∇ ResetLX
    ⍝ if ⎕LX was changed/set for the sake of this build return it to what it was before
      :If 2=⎕NC'tmp_lx'
          ⎕LX←tmp_lx
          LogBuild'⎕LX return to its original value ',tmp_lx
      :EndIf
    ∇

    ∇ LogBuild update;prefix
      prefix←'>>  '
      log,←⊂prefix,update
      :If ~suppress_output
          ⎕←prefix,update
      :EndIf
    ∇

    ∇ HandleError;tb
      tb←2⍴⎕UCS 9
      LogBuild ⎕UCS 10
      LogBuild tb,'build stopped'
      LogBuild tb,'error num: ',⎕DMX.EN
      LogBuild¨tb∘,¨⎕DMX.DM
      CleanUp
    ∇

    ∇ CleanUp
      LogBuild'clean up started'
      ResetLX
      LogBuild'clean up complete'
    ∇

    :EndSection

    :Section Preprocessing

    ∇ {files}←CheckFilesAndDirs files;bin
      files←RepBSl files
      :If ~∧/bin←⎕NEXISTS¨⊆files
          ('could not find ',CommaAndList(~bin)/files)⎕SIGNAL 3
      :EndIf
    ∇

    ∇ name←CheckName name
    ⍝ check to see if it is a valid file name
    ∇

    ∇ GetDyalogDir
      dyalog_dir←RepBSl{RM←{⍵/⍨⌽∨\⌽⍵∊'\'} ⋄ RM ¯1↓RM ⍵}⎕SE.SALTUtils.CMDDIR
    ∇

    :EndSection

    ∇ {r}←CompileAll;fns;rsp;new;old
      fns←ListAllFns
      old←+/1(400⌶)¨fns
      rsp←2(400⌶)¨fns
      new←+/0=⊃∘⍴¨rsp
      r←new old(⍴fns)
    ∇

    ∇ {r}←to CopyFiles file;ext;dir;∆CopyFile;file_name
      to←RepBSl to,'/'⍴⍨~(¯1↑to)∊'/\'
      dir file_name ext←⎕NPARTS file
      '∆CopyFile'⎕NA'I kernel32.C32|CopyFile* <0T <0T I2'
      r←∆CopyFile(⊂file),(⊂to,file_name,ext),0
    ∇

    ∇ list←{exclude}ListNS startns;exclusions;lengthbefore;lengthafter;nest;ns;ListCurrentNS
     
      :If 0=⎕NC'exclude'
          exclusions←'SALT_Var_Data' 'SALT_Data'
      :ElseIf 2=⎕NC'exclude'
          exclusions←'SALT_Var_Data' 'SALT_Data',⊆exclude
      :Else
          'Invaid exclusions'⎕SIGNAL 601
      :EndIf                                                        ⍝ start in the root ns
      ListCurrentNS←exclusions∘(RemBS{⍺~⍨⍺⍺¨↓⎕NL 9.1})  ⍝ list ns's in the current ns
      list←⊆startns
      ⎕CS'#'                                            ⍝ start with a list fromt he root
      :Repeat                                                       ⍝ repeat until all nested ns's are uncovered
          lengthbefore←⍴,⊆list
          :For ns :In list                                          ⍝ for each ns in the list
              ⎕CS ns                                                ⍝ see if it has nested ns's
              :If 0≠⍴nest←(⊂ns),¨'.',¨ListCurrentNS ⍬                      ⍝ if there are nested ns's
              :AndIf ~∨/nest∊list                                   ⍝ and if those nested ns's haven't already been added
                  list,←nest                                        ⍝ add them to the list to be explored on the next repeat
              :EndIf
          :EndFor
          lengthafter←⍴list
      :Until lengthbefore=lengthafter
    ∇

    ∇ list←{withext}ListFns ns;ext;fns
 ⍝ Funtion returns a list of funtions in a given namespace
 ⍝
 ⍝ ⍵: the namespace in which to list all functions
 ⍝ ⍺: shy boolean indicator of whether to return functions with ns extention
 ⍝      ⍺=0 then list ← 'Foo1' 'Foo2'
 ⍝      ⍺=1 then list ← '#.ns.Foo1' '#.ns.Foo2'
     
      :If 0=⎕NC'withext' ⋄ withext←1 ⋄ :EndIf  ⍝ default to having extention appended
     
      :If withext
          fns←(⊂ns,'.'),¨↓⍎ns,'.⎕NL 3'
      :Else
          fns←↓⍎ns,'.⎕NL 3'
      :EndIf
      list←RemBS¨fns
    ∇

    ∇ r←ListAllFns
      r←⊃,/1∘ListFns¨ListNS'#'
    ∇

    :Section Utils

      RemBS←{               ⍝ Remove Back Spaces (trailing blanks)
          (~⌽∧\' '=⌽⍵)/⍵
      }

      RepBSl←{              ⍝ Replace Back Slash
          ('\\'⎕R'/')⍵
      }

      FmtTS←{               ⍝ Format Time Stamp
          len←3⌈7⌊⍴⍵        ⍝ restrict the length
          ⍺←'-- ::.'        ⍝ defualt seperators
          _fmtstatment←{    ⍝ create a format statement
              _do←{
                  '⍬'∊⍺:',ZI',⍕⍵ ⋄ ',<',⍺,'>,ZI',⍕⍵
              }
              1↓⊃,/('⍬',⍺)_do¨⍵  ⍝ the first is always the year
          }
          size←4 2 2 2 2 2 3
          fmt←(⍺↑⍨len-1)_fmtstatment len↑size
          ,fmt ⎕FMT⍉⍪len↑⍵
      }

      CommaAndList←{
          1=⍴,⊆⍵:⍵
          2↓⊃,/((⊂', '),¨¯1↓⍵),(⊂' and '),¯1↑⍵
      }

    :EndSection
:EndClass
