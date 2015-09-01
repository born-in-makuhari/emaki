require 'dm-migrations'

# -----------------------------------------------
# Load all models
#
require EMAKI_ROOT + '/models/user.rb'
require EMAKI_ROOT + '/models/slide.rb'

# -----------------------------------------------
# DataMapper setup
#
DataMapper.finalize
# it doesn't drop any columns.
DataMapper.auto_upgrade!
