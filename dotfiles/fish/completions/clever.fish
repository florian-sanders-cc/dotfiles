# if "usage" is not installed show an error
if ! command -v usage &> /dev/null
    echo >&2
    echo "Error: usage CLI not found. This is required for completions to work in clever." >&2
    echo "See https://usage.jdx.dev for more information." >&2
    return 1
end

set _usage_spec_clever 'name "Clever Cloud CLI"
bin clever
version "1.0.0"
author "Clever Cloud"
about "CLI tool to manage Clever Cloud\'s data and products"
min_usage_version "1.0.0"
flag "--color --no-color" help="Enable/disable colored output"
flag "-v --verbose" help="Enable verbose output"
flag "--update-notifier --no-update-notifier" help="Enable/disable update notifier"
flag "-a --alias" help="Short name for the application" global=#true {
    arg <alias>
}
flag --app help="Application ID (or name, if unambiguous)" global=#true {
    arg <app-id>
}
flag "--org --owner" help="Organisation to target by its ID (or name, if unambiguous)" global=#true {
    arg <owner>
}
cmd login help="Login to Clever Cloud" {
    flag --token help="Directly give an existing token" {
        arg <token>
    }
    flag --secret help="Directly give an existing secret" {
        arg <secret>
    }
}
cmd deploy help="Deploy an application" {
    flag "-b --branch" help="Branch to push (current branch by default)" {
        arg <branch>
    }
    flag "-t --tag" help="Tag to push (none by default)" {
        arg <tag>
    }
    flag "-q --quiet" help="Don\'t show logs during deployment"
    flag "-f --force" help="Force deploy even if it\'s not fast-forwardable"
    flag --follow help="Continue to follow logs after deployment has ended"
    flag --same-commit-policy help="Policy to use when deploying the same commit" {
        arg <policy>
    }
    flag --exit-on help="Exit after deployment reaches specified status" {
        arg <status>
    }
}
cmd scale help="Change scalability of an application" {
    flag --flavor help="The instance size of your application" {
        arg <flavor>
    }
    flag --instances help="The number of parallel instances" {
        arg <instances>
    }
    flag --min-instances help="The minimum number of parallel instances" {
        arg <min>
    }
    flag --max-instances help="The maximum number of parallel instances" {
        arg <max>
    }
    flag --min-flavor help="The minimum instance size of your application" {
        arg <flavor>
    }
    flag --max-flavor help="The maximum instance size of your application" {
        arg <flavor>
    }
    flag --build-flavor help="The size of the build instance, or \'disabled\' if you want to disable dedicated build instances" {
        arg <flavor>
    }
}
cmd logs help="Fetch application logs, continuously" {
    flag "--before --until" help="Fetch logs before this date/time" {
        arg <before>
    }
    flag "--after --since" help="Fetch logs after this date/time" {
        arg <after>
    }
    flag --search help="Fetch logs matching this pattern" {
        arg <pattern>
    }
    flag --deployment-id help="Fetch logs for a given deployment" {
        arg <id>
    }
    flag --addon help="Add-on ID" {
        arg <addon-id>
    }
}
cmd env help="Manage environment variables of an application" {
    flag --add-export help="Display sourceable env variables setting"
    cmd set help="Add or update an environment variable" {
        arg <variable-name>
        arg <variable-value>
    }
    cmd rm help="Remove an environment variable" {
        arg <variable-name>
    }
    cmd import help="Load environment variables from STDIN" {
        flag --json help="Import variables as JSON"
    }
    cmd import-vars help="Add or update environment variables from current environment" {
        arg <variable-names>
    }
}
cmd domain help="Manage domain names for an application" {
    cmd add help="Add a domain name to an application" {
        arg <fqdn>
    }
    cmd rm help="Remove a domain name from an application" {
        arg <fqdn>
    }
    cmd favourite help="Manage the favourite domain name for an application" {
        cmd set help="Set the favourite domain for an application" {
            arg <fqdn>
        }
        cmd unset help="Unset the favourite domain for an application"
    }
    cmd diag help="Check if domains associated to a specific app are properly configured" {
        flag --filter help="Check only domains containing the provided text" {
            arg <text>
        }
    }
    cmd overview help="Get an overview of all your domains" {
        flag --filter help="Get only domains containing the provided text" {
            arg <text>
        }
    }
}
cmd service help="Manage service dependencies" {
    flag --only-apps help="Only show app dependencies"
    flag --only-addons help="Only show add-on dependencies"
    flag --show-all help="Show all available add-ons and applications"
    cmd link-app help="Add an existing app as a dependency" {
        arg <app-id>
    }
    cmd link-addon help="Link an existing add-on to this application" {
        arg <addon-id>
    }
    cmd unlink-app help="Remove an app from the dependencies" {
        arg <app-id>
    }
    cmd unlink-addon help="Unlink an add-on from this application" {
        arg <addon-id>
    }
}
cmd accesslogs help="Fetch access logs"
cmd activity help="Show last deployments of an application" {
    flag --show-all help="Show all activity"
    flag "-f --follow" help="Track new deployments in activity list"
}
cmd addon help="Manage add-ons" {
    cmd create help="Create an add-on" {
        flag "-p --plan" help="Add-on plan, depends on the provider" {
            arg <plan>
        }
        flag "-r --region" help="Region to provision the add-on in" {
            arg <region>
        }
        flag "-y --yes" help="Skip confirmation even if the add-on is not free"
        arg <addon-provider>
        arg <addon-name>
    }
    cmd delete help="Delete an add-on" {
        flag "-y --yes" help="Skip confirmation"
        arg <addon-id>
    }
    cmd rename help="Rename an add-on" {
        arg <addon-id>
        arg <addon-name>
    }
    cmd providers help="List available add-on providers" {
        cmd show help="Show information about an add-on provider" {
            arg <addon-provider>
        }
    }
    cmd env help="List environment variables for an add-on" {
        arg <addon-id>
    }
}
cmd applications help="List linked applications" {
    cmd list help="List all applications"
}
cmd cancel-deploy help="Cancel an ongoing deployment"
cmd config help="Display or edit the configuration of your application" {
    cmd get help="Display the current configuration" {
        arg <configuration-name>
    }
    cmd set help="Edit one configuration setting" {
        arg <configuration-name>
        arg <configuration-value>
    }
    cmd update help="Edit multiple configuration settings at once"
}
cmd create help="Create an application" {
    flag "-t --type" help="Instance type" {
        arg <type>
    }
    flag "-r --region" help=Region {
        arg <region>
    }
    flag --github help="GitHub application to use for deployments" {
        arg "<owner/repo>"
    }
    flag "-a --alias" help="Short name for the application" {
        arg <alias>
    }
    arg "[app-name]" required=#false
}
cmd curl help="Query Clever Cloud\'s API using Clever Tools credentials"
cmd delete help="Delete an application" {
    flag "-y --yes" help="Skip confirmation"
}
cmd diag help="Diagnose the current installation"
cmd drain help="Manage drains" {
    cmd create help="Create a drain" {
        arg <drain-type>
        arg <drain-url>
    }
    cmd remove help="Remove a drain" {
        arg <drain-id>
    }
    cmd enable help="Enable a drain" {
        arg <drain-id>
    }
    cmd disable help="Disable a drain" {
        arg <drain-id>
    }
}
cmd link help="Link this repo to an existing application" {
    flag "-a --alias" help="Short name for the application" {
        arg <alias>
    }
    arg <app-id>
}
cmd logout help="Logout from Clever Cloud"
cmd make-default help="Make a linked application the default one" {
    arg <alias>
}
cmd notify-email help="Manage email notifications" {
    cmd add help="Add a new email notification" {
        flag --notify help="Notify target"
        arg <name>
    }
    cmd remove help="Remove an existing email notification" {
        arg <notification-id>
    }
}
cmd open help="Open an application in the Console"
cmd profile help="Display the profile of the current user" {
    cmd open help="Open your profile in the Console"
}
cmd published-config help="Manage the configuration made available to other applications" {
    cmd set help="Add or update a published configuration item" {
        arg <variable-name>
        arg <variable-value>
    }
    cmd rm help="Remove a published configuration variable" {
        arg <variable-name>
    }
    cmd import help="Load published configuration from STDIN" {
        flag --json help="Import variables as JSON"
    }
}
cmd tcp-redirs help="Control TCP redirections" {
    cmd list-namespaces help="List available TCP redirection namespaces"
    cmd add help="Add a new TCP redirection" {
        flag --namespace help="Namespace for the redirection"
        flag "-y --yes" help="Skip confirmation"
    }
    cmd remove help="Remove a TCP redirection" {
        flag --namespace help="Namespace for the redirection"
        arg <port>
    }
}
cmd unlink help="Unlink this repo from an existing application" {
    arg <alias>
}
cmd version help="Display the clever-tools version"
cmd webhooks help="Manage webhooks" {
    cmd add help="Register webhook" {
        flag --format help="Webhook format"
        arg <name>
        arg <url>
    }
    cmd remove help="Remove webhook" {
        arg <notification-id>
    }
}
cmd status help="See the status of an application"
cmd restart help="Start or restart an application" {
    flag --commit help="Restart with specific commit ID" {
        arg <id>
    }
    flag --without-cache help="Restart without using cache"
    flag --follow help="Continue to follow logs after deployment"
    flag "-q --quiet" help="Don\'t show logs during deployment"
}
cmd stop help="Stop a running application"
cmd console help="Open an application in the Console"
cmd ssh help="Connect to running instances through SSH" {
    flag "-i --identity-file" help="SSH identity file" {
        arg <file>
    }
}
'
set -l tokens
if commandline -x >/dev/null 2>&1
    complete -xc clever -a '(usage complete-word --shell fish -s "$_usage_spec_clever" -- (commandline -xpc) (commandline -t))'
else
    complete -xc clever -a '(usage complete-word --shell fish -s "$_usage_spec_clever" -- (commandline -opc) (commandline -t))'
end
