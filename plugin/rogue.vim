command! -nargs=* Rogue call rogue#main(<q-args>)
command! -nargs=0 RogueScores call rogue#main('-s')
command! -nargs=? RogueRestore call rogue#main(<q-args> == '' ? '-r' : <q-args>)
command! -nargs=0 RogueResume call rogue#main('--resume')
