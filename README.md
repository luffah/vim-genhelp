```
      .--.                 .-. .-.      .-.
     / .-_\_  ___     ___  | | | | ___  | |
    | | |___|/ o \  ,'_  | | '-' |/ o \ | | .--.
     \ '-'|   \  '.| | | | | .-. | \  '.| | | o |
      '---'    '--''-' '-' '-' '-'  '--''--'| |'
                                            | |
                                            '-'

** genhelp.vim -- Helper script to generate vim help files **

License:     GPLv3
Last Change: 2018-05-19
```
GenHelp generate vim help file for the current script.

### HOW TO USE IT ?
`:GenHelp` 
    Generate an help file from the current file.
    Tag file will be written once the file is saved.

`:GenReadme` 
    Generate a simple readme from the current file.

### WHAT I HAVE TO DO BEFORE ?
To work with GenHelp, the vim script format shall be the following :<pre>
   " _filename_ -- _desc_
   " @Author:      _author_
   " @License:     _licence_
   " @Created:     _creation-date_
   " @Last Change: _modification-date_
   " @Revision:    _revision_
   " @Files
   "  ../plugin/_file_.vim
   "  ../autoload/_file_.vim
   "
   " @AsciiArt
   " _text_
   "
   " @Overview
   " _text_

   " Following properties can be located in any '@include' files

   " @Examples
   " _text_ : ```
   "     _codeblock_
   "```

   " @Fileformat g:_variablename_
   " _text_

   " @global g:_variablename_
   " _text_

   " @function _functionname_(_arguments_)
   " _text_

   " @command _commandname_ _arguments_
   " _text_

   " @usage _usecase_
   " _text_

   " @mapping _keys_
   " _text_
</pre>
