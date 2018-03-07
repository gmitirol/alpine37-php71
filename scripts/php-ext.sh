#!/bin/sh

MODE="$1";
EXTENSIONS="$2";

source php-extensions.sh

PHP_CONFIGDIR='/etc/php7/conf.d';

# Returns the config file for a PHP extension.
function get_php_extension_config_file()
{
    EXTENSION=$(echo "$1" | sed 's/^php7-//');
    CONFIGFILE_NUMBERED=$(find "$PHP_CONFIGDIR" -name "*_$EXTENSION.ini" 2> /dev/null);
    CONFIGFILE_DEFAULT=$(find "$PHP_CONFIGDIR" -name "$EXTENSION.ini" 2> /dev/null);
    if [ ! -z "$CONFIGFILE_NUMBERED" ]; then
        echo "$CONFIGFILE_NUMBERED";

        return 0;
    fi;

    if [ ! -z "$CONFIGFILE_DEFAULT" ]; then
        echo "$CONFIGFILE_DEFAULT";

        return 0;
    fi;

    return 1;
}

# Returns the status of an extension.
# "Y" - enabled via config file
# "-" - disabled via config file
# "X" - not configurable via config file
function get_php_extension_status()
{
    EXTENSION="$1";
    CONFIGFILE=$(get_php_extension_config_file "$EXTENSION");
    if [ -z "$CONFIGFILE" ]; then
        echo 'X';

        return 0;
    fi;

    if [ $(grep -E '^extension=' "$CONFIGFILE") ] || [ $(grep -E '^zend_extension=' "$CONFIGFILE") ]; then
        echo 'Y';

        return 0;
    fi;

    echo '-';

    return 0;
}

# Enables or disables a PHP extension.
function set_php_extension() {
    EXTENSION="$2";
    CONFIGFILE=$(get_php_extension_config_file "$EXTENSION");
    if [ -z "$CONFIGFILE" ]; then
        (>&2 echo "No configuration file for $EXTENSION found, skipping!");

        return 1;
    fi;

    case "$1" in
        'enabled')
            sed -i 's/^;extension=/extension=/g' "$CONFIGFILE";
            sed -i 's/^;zend_extension=/zend_extension=/g' "$CONFIGFILE";
            ;;
        'disabled')
            sed -i 's/^extension=/;extension=/g' "$CONFIGFILE";
            sed -i 's/^zend_extension=/;zend_extension=/g' "$CONFIGFILE";
            ;;
    esac

    return 0;
}

case "$MODE" in
    'enable')
        for EXTENSION in $EXTENSIONS; do
            set_php_extension enabled "$EXTENSION";
        done;

        exit 0;
        ;;
    'disable')
        for EXTENSION in $EXTENSIONS; do
            set_php_extension disabled "$EXTENSION";
        done;

        exit 0;
        ;;
    'enable-all')
        for EXTENSION in $(get_php_extensions); do
             if [ "$(get_php_extension_status $EXTENSION)" == '-' ]; then
                echo "Enabling $EXTENSION";
                set_php_extension enabled "$EXTENSION";
            fi;
        done;

        exit 0;
        ;;
    'disable-non-default')
        for EXTENSION in $(get_php_extensions); do
            for DEFAULT_EXTENSION in $(get_php_extensions_default); do
                if [ "$EXTENSION" == "$DEFAULT_EXTENSION" ]; then
                    continue 2;
                fi;
            done;

            if [ "$(get_php_extension_status $EXTENSION)" == 'Y' ]; then
                echo "Disabling $EXTENSION";
                set_php_extension disabled "$EXTENSION";
            fi;
        done;

        exit 0;
        ;;
    'show')
        AVAILABLE_EXTENSIONS=$(get_php_extensions);

        printf '%-20s' 'Extension';
        printf '%-10s' 'Enabled';
        echo 'Configuration';

        for EXTENSION in $AVAILABLE_EXTENSIONS; do
            printf '%-20s' "$EXTENSION:";
            printf '%-10s' "$(get_php_extension_status $EXTENSION)";
            echo "$(get_php_extension_config_file $EXTENSION)";
        done;

        exit 0;
        ;;
    *)
        (>&2 echo 'Invalid action!');

        exit 65;
        ;;
esac
