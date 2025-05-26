CreateThread(function()
    -- Create the bcc_camp table if it doesn't exist
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bcc_camp` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `charidentifier` int(11) NOT NULL,
            `firstname` varchar(50) NOT NULL DEFAULT '',
            `lastname` varchar(50) NOT NULL DEFAULT '',
            `campname` varchar(50) NOT NULL DEFAULT '',
            `stash` double NOT NULL DEFAULT 0,
            `furniture` text DEFAULT NULL,
            `camp_coordinates` longtext DEFAULT NULL,
            `tent_model` varchar(255) NOT NULL DEFAULT 'default_tent_model',
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
    ]])

    -- Add the `condition` column if it doesn't exist
    MySQL.query.await([[
        ALTER TABLE `bcc_camp`
        ADD COLUMN IF NOT EXISTS `condition` INT(11) NOT NULL DEFAULT 100
        AFTER `tent_model`;
    ]])

    -- Add the `last_updated` column if it doesn't exist
    MySQL.query.await([[
        ALTER TABLE `bcc_camp`
        ADD COLUMN IF NOT EXISTS `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        AFTER `condition`;
    ]])

    -- Print a success message to the console
    print("Database tables for \x1b[35m\x1b[1m*bcc-camp*\x1b[0m created or updated \x1b[32msuccessfully\x1b[0m.")
end)
