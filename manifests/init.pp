class node_versioning (
    $node_version = 'stable',
    $npm_version = 'latest',
) {

    exec {'Install n': 
        command => 'curl https://raw.githubusercontent.com/tj/n/master/bin/n > /usr/bin/n && chmod +x /usr/bin/n',
        user => root,
        provider => shell,
        creates => '/usr/bin/n',
    } -> 
    exec {'Install NodeJS':
        command => "n ${node_version} && n use ${node_version}",
        user => root,
        provider => shell,
        onlyif => "! n ls | grep ${node_version} | hexdump -C | grep -i 'ce  \\?bf'"
    } ->
    exec {'Link NodeJS':
        command => "ln -s /usr/local/bin/node /usr/bin/node",
        user => root,
        provider => shell,
        creates => '/usr/bin/node',
    }
    exec {'Link NPM':
        command => "ln -s /usr/local/bin/npm /usr/bin/npm",
        user => root,
        provider => shell,
        creates => '/usr/bin/npm',
        require => Exec['Install NodeJS'],
    }->
    exec {'Ensure NPM Version':
        command   => "npm install -gf npm@${npm_version}",
        user      => root,
        provider  => shell,
        require => Exec['Link NodeJS'],
        onlyif    => "[ \"`npm -v`\" != \"${npm_version}\" ]",
    }
}
