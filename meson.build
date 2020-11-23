# Project name and programming language
project('com.github.torikulhabib.mindi', 'vala', 'c', version: '0.1.0')

# Adds project arguments
add_project_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())
    ],
    language: 'c',
)

# Include the translations module
gnome = import('gnome')
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

subdir('src')

executable(
    meson.project_name(),
    sources,
    dependencies: [
        dependency('gio-unix-2.0', version: '>=2.20'),
        dependency('gtk+-3.0'),
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
