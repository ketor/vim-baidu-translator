"Check if py3 is supported
function! s:UsingPython3()
  if has('python3')
    return 1
  endif
  if has('python')
    return 0
  endif
  echo "Error: Required vim compiled with +python/+python3"
  finish
endfunction

let s:using_python3 = s:UsingPython3()
let s:python_until_eof = s:using_python3 ? "python3 << EOF" : "python << EOF"
let s:python_command = s:using_python3 ? "py3 " : "py "

" This function taken from the lh-vim repository
function! s:GetVisualSelection()
    try
        let a_save = @a
        normal! gv"ay
        return @a
    finally
        let @a = a_save
    endtry
endfunction

function! s:GetCursorWord()
    return expand("<cword>")
endfunction

if !exists("g:baidu_appid")
    "let g:baidu_appid='20151113000005349'
    let g:baidu_appid=''
endif

if !exists("g:baidu_secretKey")
    "let g:baidu_secretKey='osubCEzlGjzvw8qdQc41'
    let g:baidu_secretKey=''
endif

exec s:python_until_eof

# -*- coding: utf-8 -*-
import vim,urllib,re,collections,xml.etree.ElementTree as ET
import sys,json

try:
    from urllib.parse import urlparse, urlencode
    from urllib.request import urlopen, Request
    from urllib.error import HTTPError
except ImportError:
    from urlparse import urlparse
    from urllib import urlencode
    from urllib2 import urlopen, Request, HTTPError

def str_encode(word):
    if sys.version_info >= (3, 0):
        return word
    else:
        return word.encode('utf-8')

def str_decode(word):
    if sys.version_info >= (3, 0):
        return word
    else:
        return word.decode('utf-8')

def bytes_decode(word):
    if sys.version_info >= (3, 0):
        return word.decode()
    else:
        return word

def bytes_encode(word):
    if sys.version_info >= (3, 0):
        return word.encode('utf-8')
    else:
        return word

def url_quote(word):
    if sys.version_info >= (3, 0):
        return urllib.parse.quote(word)
    else:
        return urllib.quote(word.encode('utf-8'))

QUERY_BLACK_LIST = ['.', '|', '^', '$', '\\', '[', ']', '{', '}', '*', '+', '?', '(', ')', '&', '=', '\"', '\'', '\t']

def preprocess_word(word):
    word = word.strip()
    for i in QUERY_BLACK_LIST:
        word = word.replace(i, ' ')
    array = word.split('_')
    word = []
    p = re.compile('[a-z][A-Z]')
    for piece in array:
        lastIndex = 0
        for i in p.finditer(piece):
            word.append(piece[lastIndex:i.start() + 1])
            lastIndex = i.start() + 1
        word.append(piece[lastIndex:])
    return ' '.join(word).strip()

def get_query_url(query):
    import hashlib
    import random
    appid = vim.eval("g:baidu_appid")
    secretKey = vim.eval("g:baidu_secretKey")

    myurl = 'http://api.fanyi.baidu.com/api/trans/vip/translate'
    fromLang = 'auto'
    toLang = 'auto'
    salt = random.randint(32768, 65536)

    sign = appid+query+str(salt)+secretKey
    m1 = hashlib.md5()
    m1.update(sign.encode('utf-8'))
    sign = m1.hexdigest()
    myurl = myurl+'?appid='+appid+'&q='+url_quote(query)+'&from='+fromLang+'&to='+toLang+'&salt='+str(salt)+'&sign='+sign

    return myurl

def query_from_baidu(query):
    try:
        word = preprocess_word(query)
        if not word:
            return ''
        r = urlopen(get_query_url(word))
    except IOError:
        return 'NETWORK_ERROR'

    response = json.loads(bytes_decode(r.read()))
    if response.get('error_code') is not None:
        return response.get('error_msg')

    response = response.get('trans_result')
    result = ''
    if response is not None and len(response) > 0:
        for i in response:
            result = result + i.get('dst') + "\n"
        return result
    else:
        return 'NO_RESULT'

def query_from_baidu_noappid(query):
    try:
        word = preprocess_word(query)
        if not word:
            return ''
        r = urlopen('http://fanyi.baidu.com/v2transapi?from=auto&to=auto&query='+url_quote(query))
    except IOError:
        return 'NETWORK_ERROR'

    response = json.loads(bytes_decode(r.read()))
    response = response.get('trans_result').get('data')
    result = ''
    if response is not None and len(response) > 0:
        for i in response:
            result = result + i.get('dst') + "\n"
        return result
    else:
        return 'NO_RESULT'

def baidu_translate_visual_selection(lines):
    lines = str_decode(lines)
    appid = vim.eval("g:baidu_appid")
    if appid != '':
        info = query_from_baidu(lines)
    else:
        info = query_from_baidu_noappid(lines)
    for line in info.split('\n'):
        vim.command('echo "'+ line +'"')
EOF

function! s:BaiduVisualTranslate()
    exec s:python_command 'baidu_translate_visual_selection(vim.eval("<SID>GetVisualSelection()"))'
endfunction

function! s:BaiduCursorTranslate()
    exec s:python_command 'baidu_translate_visual_selection(vim.eval("<SID>GetCursorWord()"))'
endfunction

function! s:BaiduEnterTranslate()
    let word = input("Please enter the word: ")
    redraw!
    exec s:python_command 'baidu_translate_visual_selection(vim.eval("word"))'
endfunction

command! Bdv call <SID>BaiduVisualTranslate()
command! Bdc call <SID>BaiduCursorTranslate()
command! Bde call <SID>BaiduEnterTranslate()

