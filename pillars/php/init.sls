# https://www.owasp.org/index.php/PHP_Configuration_Cheat_Sheet
php:
  use_external_repo: False
  ng:
    apache2:
      ini:
        opts:
          replace: True
        settings:
          # Default for Debian libapache2-mod-php7.0 package with additional
          # disable_functions entries
          PHP:
            engine: 'On'
            short_open_tag: 'Off'
            precision: 14
            output_buffering: 4096
            zlib.output_compression: 'Off'
            implicit_flush: 'Off'
            unserialize_callback_func: ''
            serialize_precision: 17
            disable_functions:
              - apache_child_terminate
              - apache_get_modules
              - apache_get_version
              - apache_getenv
              - apache_note
              - apache_setenv
              - disk_free_space
              - disk_total_space
              - diskfreespace
              - dl
              - exec
              - link
              - opcache_get_configuration
              - opcache_get_status
              - passthru
              - pclose
              - pcntl_alarm
              - pcntl_exec
              - pcntl_exec
              - pcntl_fork
              - pcntl_get_last_error
              - pcntl_getpriority
              - pcntl_setpriority
              - pcntl_signal
              - pcntl_signal_dispatch
              - pcntl_sigprocmask
              - pcntl_sigtimedwait
              - pcntl_sigwaitinfo
              - pcntl_strerror
              - pcntl_wait
              - pcntl_waitpid
              - pcntl_wexitstatus
              - pcntl_wifcontinued
              - pcntl_wifexited
              - pcntl_wifsignaled
              - pcntl_wifstopped
              - pcntl_wstopsig
              - pcntl_wtermsig
              - popen
              - posix_getpwuid
              - posix_kill
              - posix_mkfifo
              - posix_setpgid
              - posix_setsid
              - posix_setuid
              - posix_uname
              - proc_close
              - proc_get_status
              - proc_nice
              - proc_open
              - proc_terminate
              - putenv
              - shell_exec
              - show_source
              - symlink
              - system
            zend.enable_gc: 'On'
            expose_php: 'Off'
            max_execution_time: 30
            max_input_time: 60
            memory_limit: 128M
            error_reporting:
              - E_ALL
              - ~E_DEPRECATED
              - ~E_STRICT
            display_errors: 'Off'
            display_startup_errors: 'Off'
            log_errors: 'On'
            log_errors_max_len: 1024
            ignore_repeated_errors: 'Off'
            ignore_repeated_source: 'Off'
            report_memleaks: 'On'
            track_errors: 'Off'
            html_errors: 'On'
            variables_order: 'GPCS'
            request_order: 'GP'
            register_argc_argv: 'Off'
            auto_globals_jit: 'On'
            post_max_size: 8M
            auto_prepend_file: ''
            auto_append_file: ''
            default_mimetype: 'text/html'
            default_charset: 'UTF-8'
            doc_root: ''
            user_dir: ''
            enable_dl: 'Off'
            file_uploads: 'On'
            upload_max_filesize: 2M
            max_file_uploads: 20
            allow_url_fopen: 'On'
            allow_url_include: 'Off'
            default_socket_timeout: 60
{# Default disable_functions list for Debian libapache2-mod-php7.0 package:
              - pcntl_alarm
              - pcntl_exec
              - pcntl_fork
              - pcntl_get_last_error
              - pcntl_getpriority
              - pcntl_setpriority
              - pcntl_signal
              - pcntl_signal_dispatch
              - pcntl_sigprocmask
              - pcntl_sigtimedwait
              - pcntl_sigwaitinfo
              - pcntl_strerror
              - pcntl_wait
              - pcntl_waitpid
              - pcntl_wexitstatus
              - pcntl_wifcontinued
              - pcntl_wifexited
              - pcntl_wifsignaled
              - pcntl_wifstopped
              - pcntl_wstopsig
              - pcntl_wtermsig
#}
