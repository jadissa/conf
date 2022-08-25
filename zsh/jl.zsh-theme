# purple username
username() {
   echo "%{$FG[012]%}%n%{$reset_color%}"
}

# current directory, two levels deep
directory() {
   echo "%~"
}

# current time with milliseconds
current_time() {
   echo "%*"
}

# returns 👾 if there are errors, nothing otherwise
return_status() {
   echo "%(?..👾)"
}

# set base colors
if [[ $terminfo[colors] -ge 256 ]]; then
  purple="%F{49}"
else
  purple="%F{magenta}"
fi

# set the git_prompt_status text
ZSH_THEME_GIT_PROMPT_ADDED="%{$purple%}%✈%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$purple%}%✭%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$purple%}%✗%{$reset_color%}"

# putting it all together
PROMPT='%B$(current_time) $(directory) $(git_prompt_info)%b '