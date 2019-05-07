" genhelp.vim -- Helper script to generate vim help files
" @Author:       luffah
" @License:      GPLv3
" @Created:      2018-05-19
" @Last Change:  2018-05-19
" @Revision:     1
" @AsciiArt
"   .--.                 .-. .-.      .-.
"  / .-_\_  ___     ___  | | | | ___  | |
" | | |___|/ o \  ,'_  | | '-' |/ o \ | | .--.
"  \ '-'|   \  '.| | | | | .-. | \  '.| | | o |
"   '---'    '--''-' '-' '-' '-'  '--''--'| |'
"                                         | |
"                                         '-'
" @Overview
" GenHelp generate vim help file for the current script.
" 
" @fileformat
" To work with GenHelp, the vim script format shall be the following : ```
"    " _filename_ -- _desc_
"    " @Author:      _author_
"    " @License:     _licence_
"    " @Created:     _creation-date_
"    " @Last Change: _modification-date_
"    " @Revision:    _revision_
"    " @Files
"    "  ../plugin/_file_.vim
"    "  ../autoload/_file_.vim
"    "
"    " @AsciiArt
"    " _text_
"    "
"    " @Overview
"    " _text_
"
"    " Following properties can be located in any '@include' files
"
"    " @Examples
"    " _text_ : ```
"    "     _codeblock_
"    "```
"
"    " @Fileformat g:_variablename_
"    " _text_
"
"    " @global g:_variablename_
"    " _text_
"
"    " @function _functionname_(_arguments_)
"    " _text_
"
"    " @command _commandname_ _arguments_
"    " _text_
"
"    " @usage _usecase_
"    " _text_
"
"    " @mapping _keys_
"    " _text_
"```
" @-------------------------------------------------------------------
" License: GPLv3
" Copyright (C) 2018  luffah <luffah@runbox.com>
" Author: luffah <luffah@runbox.com>
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.
"
"""


let s:parsing_table_head_file = [
      \ ['asciiart', '', 'asciiart',
      \  '^\("\s*@.*\|[^"].*\)\?$',
      \  '\(.*\)','\n%=',4],
      \ ['overview', '', 'overview',
      \  '^\s*\("\s*@.*\|[^"].*\)\?$',
      \  '\(.*\)','\n%=',0]
      \]

let s:parsing_table_all_files = [
      \ ['usage', 'usage', 'usage',
      \  '^\s*\("\s*@.*\|[^"].*\)\?$',
      \  '\([a-zA-Z0-9#:]*\)\(.*\)','\n*\1*\2',4],
      \ ['installation', 'installation', 'installation',
      \  '^\s*\("\s*@.*\|[^"].*\)\?$',
      \  '\(.*\)','',0],
      \ ['fileformat', 'file format', 'fileformats\?',
      \  '^\s*\("\s*@.*\|[^"].*\)\?$',
      \  '\(.\+\)','\n\1',0],
      \ ['functions', 'functions', 'function',
      \  '^\s*fu',
      \  '\([a-zA-Z0-9#]*(\)\(.*\)','\n\1\2%=*\1)*',4],
      \ ['commands', 'commands', 'command',
      \  '^\s*com',
      \  '\([a-zA-Z0-9#:]*\)\(.*\)','\n*\1*\2',4],
      \ ['globals', 'globals', 'global',
      \  '^\s*\("\s*@.*\|[^"].*\)\?$',
      \  '\(g:[a-zA-Z0-9#_]*\)\(.*\)','\n*\1*\2',4],
      \ ['mappings', 'keymappings', '\(mappings\?\|km\)',
      \  '^\s*\("\s*@.*\|[^"].*\)\?$',
      \  '\([a-zA-Z0-9#]*\)\(.*\)','\n*\1*\2',4],
      \ ['customize', 'custom settings', 'customize',
      \  '^\s*\("\s*@.*\|[^"].*\)\?$',
      \  '\s*\(.\+\)\s*$','\n\1',0],
      \ ['examples', 'examples', 'examples\?',
      \  '^\s*\("\s*@.*\|[^"].*\)\?$',
      \  '\(.*\)','\n%=',0]
      \ ]
fu! s:right_align(str)
  return printf("%78s",a:str)
endfu


fu! s:toc(...)
  let l:obj={'idx_ref':[],'text':"",'add':function('s:add_toc'),
        \'prefix':get(a:000,0,''),'parts':{},'render':function('s:render')}
  return l:obj
endfu

let s:page_width=78
fu! s:add_toc(ref,name,content,add) dict
  let l:content=""
  if !has_key(self.parts, a:ref)
    let self.parts[a:ref]=""
  endif
  if len(a:content)
    if (len(self.parts[a:ref]) == 0)
      if a:add 
        call add(self.idx_ref,a:ref)
        let l:elt=len(self.idx_ref).'. '.toupper(a:name[0]).a:name[1:]
        let self.text.="\n".printf("%s%".(s:page_width-len(l:elt))."s", l:elt,
              \'|'.(self.prefix.a:ref).'|')
      endif
      if len(a:name)
        if a:add
          let self.parts[a:ref].="\n\n".s:title_like(a:name,'*'.self.prefix.a:ref.'*')
        else
          let self.parts[a:ref].=a:name
        endif
      endif
    endif

    let self.parts[a:ref].=a:content
  endif
endfu

fu! s:common_subst(strtab)
  let l:t=map(a:strtab,'substitute(v:val,''^\s*"\s\?'','''','''')')
  let l:op=0
  for l:i in range(len(l:t))
    if l:t[l:i] =~ '^```' && l:op
      let l:t[l:i] = substitute(l:t[l:i],'^```','<','')
      let l:op=0
    endif
    if l:t[l:i] =~ '\s*```$' && !l:op
      let l:t[l:i] = substitute(l:t[l:i],'\s*```$',' >','')
      let l:op=1
    endif
  endfor
  return l:t
endfu

fu! s:common_format(strtab,formatin,formatout,indent)
  let l:strtab=[]
  if a:strtab[0] =~ '^@\w\+\s\+.*'
    let l:frstt=split(
          \substitute(a:strtab[0],'^@\w\+\s\+'.a:formatin, a:formatout,'')
          \,'%=')
  else
    let l:frstt=[]
  endif
  let l:frst=len(l:frstt)?(len(l:frstt)>1?
        \printf("%s%".(s:page_width-len(l:frstt[0]))."s",l:frstt[0],l:frstt[1])
        \:l:frstt[0]):''
  call add(l:strtab, l:frst)
  for l:i in range(len(a:strtab))[1:]
    if a:strtab[l:i] =~ '^<'
      if a:strtab[l:i] == '<'
        call add(l:strtab, a:strtab[l:i])
      else
        call add(l:strtab, substitute(a:strtab[l:i],
              \ '^<',
              \ '<'.repeat(' ',a:indent),''))
      endif
    else
      call add(l:strtab, substitute(a:strtab[l:i],
            \ '^',
            \ repeat(' ',a:indent),''))
    endif
  endfor
  return l:strtab
endfu

fu! s:inline_parser(docref)
  0
  let l:t=[]
  let l:_begin = search('\c^" @'.a:docref.':','W')
  while l:_begin
    call add(l:t, substitute(getline(l:_begin),'"\s*@'.a:docref.':\s*','',''))
    let l:_begin = search('\c^" @'.a:docref.':','W')
  endwhile
  return join(l:t,', ').(len(l:t)?"\n":"")
endfu

"fu! s:common_parser(docref,endsignal,in,out,indent)
fu! s:common_parser(docref,...)
  if type(a:docref) == type([])
     let l:docref = a:docref[0]
     let l:endsignal = a:docref[1]
     let l:in = a:docref[2]
     let l:out = a:docref[3]
     let l:indent = a:docref[4]
  elseif len(a:000) == 4
     let l:docref = a:docref
     let l:endsignal = a:1
     let l:in = a:2
     let l:out = a:3
     let l:indent = a:4
  else
     throw "Wrong number of arguments for s:common_parser"
  endif
  0
  let l:_content = ''
  let l:_begin = search('\c^" @'.l:docref,'Wc')
  while l:_begin
    let l:_end = search(l:endsignal,'W')
    let l:_content .= join(s:common_format(
          \s:common_subst(getline(l:_begin,l:_end-1)),
          \ l:in, l:out,l:indent),"\n")."\n"
    let l:_begin = search('\c^" @'.l:docref,'W')
  endwhile
  return l:_content
endfu

fu! s:getline(docref,endsignal)
  let l:lines = []
  let l:_begin = search('\c^" @'.a:docref,'Wc')
  while l:_begin
    let l:_end = search(a:endsignal,'W')
    call extend(l:lines, map(getline(l:_begin,l:_end-1),'substitute(v:val,''^"\s*'','''','''')'))
    let l:_begin = search('\c^" @'.a:docref,'W')
  endwhile
  return l:lines
endfu

fu! s:title_like(title,tags)
  let l:ret = repeat("=",s:page_width)."\n"
  let l:ret.=printf("%s%".(s:page_width-len(a:title))."s",
        \ toupper(a:title), a:tags)
  return l:ret."\n"
endfu

fu! s:render(fname,headtags) dict
  let l:ret = '*'.a:fname.'*    '.self.parts.titling
  let l:ret.=printf("\n%".s:page_width."s\n",a:headtags)
  if len(self.parts.asciiart)
    let l:ret.=' >'
    let l:ret.=self.parts.asciiart
    let l:ret.="<\n"
  endif
  let l:ret.=self.parts.license
  let l:ret.=self.parts.authors
  let l:ret.=self.parts.revision
  let l:ret.=self.parts.lastchange
  let l:ret.=self.parts.overview
  if len(self.text) && len(self.idx_ref)
    let l:ret.=s:title_like('CONTENTS', '*'.self.prefix . 'contents*')
    let l:ret.=self.text
  endif
  for l:i in self.idx_ref
    let l:ret.=self.parts[l:i]
  endfor
  return split(l:ret."\nvim:tw=78:ts=8:ft=help:norl:","\n")
endfu

fu! s:GenHelp()
  " let l:file=expand('%:p')
  let l:fname = expand('%:t')
  let l:filepath = expand('%:p:h')
  let l:docfname = expand('%:t:s?.vim?.txt?')
  let l:plugpath = substitute(expand('%:p:h'), '/\(autoload\|plugin\).*', '', '')
  let l:plugname = split(l:plugpath, '/')[-1]


  echo " ,- Gen Help"
  echo ",\--. "
  echo "| '-' on '".l:plugname."'"
  echo "| "

  let l:orig_buf = bufnr('%')
  let l:included = split(s:inline_parser('includes\?'),",")
  call extend(l:included, s:getline('files\?','^\("\s*[^ ./].*\|[^"].*\)\?$')[1:])
  " let l:included=uniq(sort(l:included))
  let l:included = uniq(l:included)
  let l:buffers = [l:orig_buf]
  for l:i in l:included
    exe 'e '.l:filepath.'/'.l:i 
    call add(l:buffers, bufnr('%'))
  endfor
  let l:toc = s:toc(l:plugname.'-')
  exe 'bu '.l:orig_buf
  redraw
  call l:toc.add('titling'  ,'',substitute(getline(1),'^" .* -- \(.*\)','\1',''),0)
  call l:toc.add('license'   ,"License:     " , s:inline_parser('license'),0)
  call l:toc.add('authors'   ,"Author(s):   " , s:inline_parser('author'),0)
  call l:toc.add('revision'  ,"Revision:    " , s:inline_parser('revision'),0)
  call l:toc.add('lastchange',"Last Change: " , s:inline_parser('last change'),0)

  for [l:tag, l:section, l:docref_regex, l:docend_regex, l:parse_regex, l:print_regex, l:indent] in s:parsing_table_head_file
    call l:toc.add(l:tag,l:section,
          \ s:common_parser(l:docref_regex,l:docend_regex,
          \                 l:parse_regex,l:print_regex,l:indent)
          \,0)
  endfor
  for l:buf in l:buffers 
    exe 'bu '.l:buf
    " redraw
    for [l:tag, l:section, l:docref_regex, l:docend_regex, l:parse_regex, l:print_regex, l:indent] in s:parsing_table_all_files
      call l:toc.add(l:tag,l:section,
            \ s:common_parser(l:docref_regex,l:docend_regex,
            \                 l:parse_regex,l:print_regex,l:indent)
            \,1)
    endfor
  endfor
  exe 'bu '.l:orig_buf
  let l:content = l:toc.render(l:fname,'*'.l:plugname.'*')
  echo " ,-' "
  silent! call mkdir(l:plugpath."/doc", "p", 0700)
  exe 'tabnew '.l:plugpath.'/doc/'.l:docfname
  %delete
  call setline(1,l:content)
  0
  echomsg "Use ':setf help' to see this buffer as an helpfile."
  echomsg "When this file will be saved, helptags will be generate."
  au BufWritePost <buffer> helptags %:p:h
endfu

fu! s:GenReadme(ext)
  " let l:file = expand('%:p')
  let l:fname = expand('%:t')
  let l:plugpath = substitute(expand('%:p:h'), '/\(autoload\|plugin\).*', '', '')
  let l:plugname = split(l:plugpath, '/')[-1]
  let l:ext = ( len(a:ext) && a:ext[0]!='.' )? '.'.a:ext : a:ext
  if filereadable(l:plugpath.'/README'.l:ext)
    let l:rep = input("README".l:ext." file aleady exists. Force (yes/no) ? ")
    if l:rep !~ 'y\(es\)\?'
      return
    endif
    redraw
  endif

  let l:parse_h = {}
  for l:i in s:parsing_table_head_file + s:parsing_table_all_files
    let l:parse_h[l:i[0]] = l:i[2:]
  endfor
  if len(l:ext)
    let l:subst_pre = 'substitute(substitute(v:val,'' >$'',"<pre>",""),''^<$'',"</pre>","")'
    let l:subst_usage = 'substitute(v:val,''^\*:\([^*]\+\)\*\( \?.*\)'',''`:\1\2` '',"g")'
    let l:head_open = '```'
    let l:head_close = '```'
  else
    let l:subst_pre = 'substitute(substitute(v:val,'' >$'',"",""),''^<$'',"","")'
    let l:subst_usage = 'substitute(v:val,''^\*:\([^*]\+\)\*\( \?.*\)'',''\n:\1\2'',"g")'
    let l:head_open = "\n"
    let l:head_close = ''
  endif
  echo " ,- Gen README".l:ext
  echo ",\--. "
  echo "| '-' on '".l:plugname."'"
  echo "| "

  let l:content = l:head_open
  let l:content.=s:common_parser(l:parse_h['asciiart'])."\n"
  let l:content.='** '.substitute(getline(1),'^"\s*','','')." **\n\n"
  let l:content.="License:     " . s:inline_parser('license')
  " let l:content.="Author(s):   " . s:inline_parser('author')
  " let l:content.="Revision:    " . s:inline_parser('revision')
  let l:content.="Last Change: " . s:inline_parser('last change')
  let l:content.= l:head_close."\n"

  let l:content.=join( map(
        \     split(s:common_parser(l:parse_h['overview']),"\n")
        \     ,l:subst_pre
        \ ), "\n")."\n"
  let l:howtocontent =join( map(
        \     split(s:common_parser(l:parse_h['commands']),"\n")
        \     ,l:subst_usage
        \ ), "\n")
  let l:howtocontent.=join( map(
        \     split(s:common_parser(l:parse_h['usage']),"\n")
        \     ,l:subst_usage
        \ ), "\n")
  let l:howtocontent.=s:common_parser(l:parse_h['mappings'])
  let l:prereqcontent =join( map(
        \     split(s:common_parser(l:parse_h['fileformat']),"\n")
        \     ,l:subst_pre
        \ ),  "\n")
  if len(l:howtocontent)
    let l:content.="### HOW TO USE IT ?\n"
    let l:content.=l:howtocontent
  endif
  if len(l:prereqcontent)
    let l:content.="\n\n### WHAT I HAVE TO DO BEFORE ?\n"
    let l:content.=l:prereqcontent
  endif
  let l:content.="\n"
  echo " ,-' "
  exe 'tabnew '.l:plugpath.'/README'.l:ext
  %delete
  call setline(1,split(l:content,"\n"))
  0
endfu

fu! s:open(file)
  if filereadable(a:file)
    exe 'tabnew '.a:file
    return 1
  else
    echoerr a:file.' is not readable'
    return 0
  endif
endfu

" @function genhelp#GenHelp(filename)
" Generate an help file.
" Usage : vim -c "call genhelp#GenHelp('path/to/file')"
fu! genhelp#GenHelp(file)
  if s:open(a:file)
    autocmd!
    call s:GenHelp()
    w
  endif
endfu

" @function genhelp#GenReadme(filename, ext)
" Generate a Readme file.
" Usage : vim -c "call genhelp#GenReadme('path/to/file', '.md')"
fu! genhelp#GenReadme(file, ext)
  if s:open(a:file)
    autocmd!
    call s:GenReadme(a:ext)
    w
  endif
endfu

" @Usage :GenHelp
" Generate an help file from the current file.
" Tag file will be written once the file is saved.
command! GenHelp call s:GenHelp()

" @Usage :GenReadme
" Generate a simple readme from the current file.
command! -nargs=* GenReadme call s:GenReadme(<q-args>)
