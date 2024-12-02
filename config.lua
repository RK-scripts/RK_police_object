
Config = {}

Config.Jobs = {
    ['police'] = 0,
    ['sheriff'] = 0,
    ['sahp'] = 0,
    ['us_army'] = 0,
}

Config.RegisterKeyMapping = {
    description = 'Menu on objects',
    device = 'keyboard',
    key = 'F10'
}

Config.Command = 'pdprops'

Config.Locale = {
    notifications = {
        cooldown = 'You cant put objects down that fast!',
        removing_object = 'Stai rimuovendo l\'oggetto'
    },
    menu = {
        title = 'Oggetti Polizia',
        options = {
            cone = 'Cono',
            spikestrip = 'Striscia chiodata',
            barrier = 'Barriera'
        }
    }
}