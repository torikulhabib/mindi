icon_sizes = ['16', '24', '32', '48', '64', '128', '256']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
        rename: meson.project_name() + '.svg'
    )
    install_data(
        join_paths('icons', i + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps'),
        rename: meson.project_name() + '.svg'
    )
endforeach

icon_sizes = ['48']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.mp4.svg'),
        join_paths('icons', i, meson.project_name() + '.flv.svg'),
        join_paths('icons', i, meson.project_name() + '.webm.svg'),
        join_paths('icons', i, meson.project_name() + '.avi.svg'),
        join_paths('icons', i, meson.project_name() + '.mpg.svg'),
        join_paths('icons', i, meson.project_name() + '.mpeg.svg'),
        join_paths('icons', i, meson.project_name() + '.mkv.svg'),
        join_paths('icons', i, meson.project_name() + '.aiff.svg'),
        join_paths('icons', i, meson.project_name() + '.mmf.svg'),
        join_paths('icons', i, meson.project_name() + '.aac.svg'),
        join_paths('icons', i, meson.project_name() + '.ac3.svg'),
        join_paths('icons', i, meson.project_name() + '.flac.svg'),
        join_paths('icons', i, meson.project_name() + '.m4a.svg'),
        join_paths('icons', i, meson.project_name() + '.mp3.svg'),
        join_paths('icons', i, meson.project_name() + '.wav.svg'),
        join_paths('icons', i, meson.project_name() + '.wma.svg'),
        join_paths('icons', i, meson.project_name() + '.ogg.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'mimetypes')
    )
    install_data(
        join_paths('icons', i, meson.project_name() + '.mp4.svg'),
        join_paths('icons', i, meson.project_name() + '.flv.svg'),
        join_paths('icons', i, meson.project_name() + '.webm.svg'),
        join_paths('icons', i, meson.project_name() + '.avi.svg'),
        join_paths('icons', i, meson.project_name() + '.mpg.svg'),
        join_paths('icons', i, meson.project_name() + '.mpeg.svg'),
        join_paths('icons', i, meson.project_name() + '.mkv.svg'),
        join_paths('icons', i, meson.project_name() + '.aiff.svg'),
        join_paths('icons', i, meson.project_name() + '.mmf.svg'),
        join_paths('icons', i, meson.project_name() + '.aac.svg'),
        join_paths('icons', i, meson.project_name() + '.ac3.svg'),
        join_paths('icons', i, meson.project_name() + '.flac.svg'),
        join_paths('icons', i, meson.project_name() + '.m4a.svg'),
        join_paths('icons', i, meson.project_name() + '.mp3.svg'),
        join_paths('icons', i, meson.project_name() + '.wav.svg'),
        join_paths('icons', i, meson.project_name() + '.wma.svg'),
        join_paths('icons', i, meson.project_name() + '.ogg.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'mimetypes')
    )
endforeach

install_data(
    meson.project_name() + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)
install_data(
    meson.project_name() + '.contract',
    install_dir: join_paths(get_option('datadir'), 'contractor')
)

i18n.merge_file(
    input:  meson.project_name() + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)
i18n.merge_file(
    input: meson.project_name() + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)
