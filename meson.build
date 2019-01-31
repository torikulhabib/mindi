# project name and programming language
project('com.github.torikulhabib.mindi', 'vala', 'c', version: '0.1.0')

gnome = import('gnome')

message ('project name and programming language')

# Adds project arguments
message ('Adds project arguments')

add_project_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())
    ],
    language: 'c',
)

# Include the translations module
message('Include the translations module')

i18n = import('i18n')

# Set our translation domain
message ('Set our translation domain')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

subdir('po')
# Adding deps
message ('Listing dependencies')

dependencies = [
    dependency('gio-unix-2.0', version: '>=2.20'),
    dependency('granite'),
    dependency('gtk+-3.0'),
]

# Adds subfolders specific build system
message ('Adds subfolders specific build system')

icon_sizes = ['16', '24', '32', '48', '64', '128', '256']

foreach i : icon_sizes
    install_data(
        join_paths('data/icons', i + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
        rename: meson.project_name() + '.svg'
    )
    install_data(
        join_paths('data/icons', i + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps'),
        rename: meson.project_name() + '.svg'
    )
endforeach

icon_sizes = ['48']

foreach i : icon_sizes
    install_data(
        join_paths('data/icons', i, meson.project_name() + '.mp4.svg'),
        join_paths('data/icons', i, meson.project_name() + '.flv.svg'),
        join_paths('data/icons', i, meson.project_name() + '.webm.svg'),
        join_paths('data/icons', i, meson.project_name() + '.avi.svg'),
        join_paths('data/icons', i, meson.project_name() + '.mpg.svg'),
        join_paths('data/icons', i, meson.project_name() + '.mpeg.svg'),
        join_paths('data/icons', i, meson.project_name() + '.mkv.svg'),
        join_paths('data/icons', i, meson.project_name() + '.aiff.svg'),
        join_paths('data/icons', i, meson.project_name() + '.mmf.svg'),
        join_paths('data/icons', i, meson.project_name() + '.aac.svg'),
        join_paths('data/icons', i, meson.project_name() + '.ac3.svg'),
        join_paths('data/icons', i, meson.project_name() + '.flac.svg'),
        join_paths('data/icons', i, meson.project_name() + '.m4a.svg'),
        join_paths('data/icons', i, meson.project_name() + '.mp3.svg'),
        join_paths('data/icons', i, meson.project_name() + '.wav.svg'),
        join_paths('data/icons', i, meson.project_name() + '.wma.svg'),
        join_paths('data/icons', i, meson.project_name() + '.ogg.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'mimetypes')
    )
    install_data(
        join_paths('data/icons', i, meson.project_name() + '.mp4.svg'),
        join_paths('data/icons', i, meson.project_name() + '.flv.svg'),
        join_paths('data/icons', i, meson.project_name() + '.webm.svg'),
        join_paths('data/icons', i, meson.project_name() + '.avi.svg'),
        join_paths('data/icons', i, meson.project_name() + '.mpg.svg'),
        join_paths('data/icons', i, meson.project_name() + '.mpeg.svg'),
        join_paths('data/icons', i, meson.project_name() + '.mkv.svg'),
        join_paths('data/icons', i, meson.project_name() + '.aiff.svg'),
        join_paths('data/icons', i, meson.project_name() + '.mmf.svg'),
        join_paths('data/icons', i, meson.project_name() + '.aac.svg'),
        join_paths('data/icons', i, meson.project_name() + '.ac3.svg'),
        join_paths('data/icons', i, meson.project_name() + '.flac.svg'),
        join_paths('data/icons', i, meson.project_name() + '.m4a.svg'),
        join_paths('data/icons', i, meson.project_name() + '.mp3.svg'),
        join_paths('data/icons', i, meson.project_name() + '.wav.svg'),
        join_paths('data/icons', i, meson.project_name() + '.wma.svg'),
        join_paths('data/icons', i, meson.project_name() + '.ogg.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'mimetypes')
    )
endforeach

install_data(
    join_paths('data',  meson.project_name() + '.gschema.xml'),
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)
install_data(
    join_paths('data', meson.project_name() + '.contract'),
    install_dir: join_paths(get_option('datadir'), 'contractor')
)
config_data = configuration_data()
config_data.set('EXEC_NAME', meson.project_name())

# Src build
message ('Src build')

conf_data = configuration_data()
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set_quoted('PREFIX', get_option('prefix'))

message ('Configuring desktop entry: ' + meson.project_name() + '.desktop')

desktop_in_file = configure_file(
    input: join_paths('data', meson.project_name() + '.desktop.in.in'),
    output: '@BASENAME@',
    configuration: config_data
)

desktop_file = i18n.merge_file(
    input: desktop_in_file,
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

appstream_file = i18n.merge_file(
    input: join_paths (meson.source_root(), 'data', meson.project_name() + '.appdata.xml.in'),
    output: '@BASENAME@',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

message ('Adds files to build')

code_files = files(
    'src/Application.vala',
    'src/Window.vala',
    'src/Settings.vala',
    'src/Utils/TimeUtil.vala',
    'src/Widgets/Audio.vala',
    'src/Widgets/Dialog.vala',
    'src/Widgets/MessageDialog.vala',
    'src/Widgets/Toast.vala',
    'src/Widgets/LightDark.vala',
    'src/Widgets/Notify.vala',
    'src/Widgets/StreamPc.vala',
    'src/Objects/Converter.vala'
)

message ('Defines executable')

executable(
    meson.project_name(),
    code_files,
    dependencies: dependencies,
    install: true
)
meson.add_install_script('meson/post_install.py')
