#compdef strata

_strata() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    # Top-level: either the `name` subcommand or the overview flags.
    _arguments -C \
        '(-h --help)'{-h,--help}'[show help]' \
        '(-V --version)'{-V,--version}'[show version]' \
        '(-p --plain)'{-p,--plain}'[non-interactive overview (colored on a terminal, bare when piped)]' \
        '--agent[non-interactive overview for agents: no color, names tagged nick/label/dev]' \
        '1: :->cmd' \
        '*:: :->args' \
        && return 0

    case $state in
        cmd)
            _describe -t commands 'strata command' '(
                name:"give a disk/partition a nickname"
            )'
            ;;
        args)
            case $line[1] in
                name)
                    # strata name <selector> [nickname] [-c|--clear]
                    _arguments \
                        '(-c --clear)'{-c,--clear}'[remove the nickname]' \
                        '1:selector (kernel name, /dev path, mountpoint, label, or nickname):' \
                        '2:nickname:'
                    ;;
            esac
            ;;
    esac
}

if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
    _strata "$@"
else
    compdef _strata strata
fi
