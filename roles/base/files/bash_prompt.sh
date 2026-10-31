# Coloured prompt like GNOME Terminal on Ubuntu, plus the git branch.
# Ubuntu's .bashrc only colours the prompt when TERM is *-256color, which
# kitty's xterm-kitty isn't at that point, so it falls back to a plain one.
[ -r /usr/lib/git-core/git-sh-prompt ] && . /usr/lib/git-core/git-sh-prompt

__prompt_git() {
    type __git_ps1 >/dev/null 2>&1 && __git_ps1 ' (%s)'
}

PS1='${debian_chroot:+($debian_chroot)}\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00;33m\]$(__prompt_git)\[\e[00m\]\$ '
# Window title: user@host: dir
PS1="\[\e]0;\u@\h: \w\a\]$PS1"
