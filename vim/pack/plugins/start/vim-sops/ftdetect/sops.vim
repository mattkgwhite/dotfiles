function! s:sops(subcmd) abort
  if !executable('sops')
    echoerr 'sops: not found in your PATH'
    return
  endif
  if a:subcmd == 'encrypt'
    setlocal ft=sops
  elseif a:subcmd == 'decrypt'
    setlocal ft=yaml
  else
    echoerr 'Only "encrypt" or "decrypt" will be accepted for subcommand'
    return
  endif
  let cmd = printf('sops --%s', a:subcmd)
  call setqflist([])
  let tmpfile = ''
  if stridx(cmd, '%s') > -1
    let tmpfile = tempname()
    let cmd = substitute(cmd, '%s', tr(tmpfile, '\', '/'), 'g')
    let lines = system(cmd, iconv(join(getline(1, '$'), "\n"), &encoding, 'utf-8'))
    if v:shell_error != 0
      call delete(tmpfile)
      echoerr substitute(lines, '[\r\n]', ' ', 'g')
      return
    endif
    let lines = join(readfile(tmpfile), "\n")
    call delete(tmpfile)
  else
    let lines = system(cmd, iconv(join(getline(1, '$'), "\n"), &encoding, 'utf-8'))
    if v:shell_error != 0
      echoerr substitute(lines, '[\r\n]', ' ', 'g')
      return
    endif
  endif
  let pos = getcurpos()
  silent! %d _
  call setline(1, split(lines, "\n"))
  call setpos('.', pos)
endfunction

nnoremap <silent> <Plug>(sops) :<C-u>call <SID>sops()<CR>

command! -nargs=0 SopsEncrypt call <SID>sops('encrypt')
command! -nargs=0 SopsDecrypt call <SID>sops('decrypt')

au BufNewFile,BufRead *.yml,*.yaml call s:detect_sops()

function! s:detect_sops()
  let n = 1
  while n < 10 && n < line('$')
    if getline(n) =~ 'ANSIBLE_VAULT'
      set filetype=sops
      " if confirm('Decrypt with SOPS?', "yes\nNo", 2) == 1
      "   SopsDecrypt
      " endif
    endif
    let n = n + 1
  endwhile
endfunction
