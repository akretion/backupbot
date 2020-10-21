# backupbot
backup gem utility for Docky and other Odoo hosting stacks.


    backupgem:schedule <name> <bucket>, Schedules a backup of the backupgem service using Backupgem
    backupgem:unschedule <name>, Unschedules the backup of the postgres service
    backupgem:backup <name> [kind], Backup db and filestore [kind] of backup on all apps and their registered databases
    backupgem:restore <name> [db_name] [backup_name], Restores a local backup

