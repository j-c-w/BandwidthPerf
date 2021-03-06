#!/usr/bin/env zunit

@test 'Load value from config' {
	load ../general/parse_config.sh
	run get_config_value key config

	assert $output same_as value
}

@test 'Load value with space from config' {
	load ../general/parse_config.sh
	run get_config_value 'space key'

	assert "$output" same_as "space value"
}

@test 'Load value from non-default config' {
	load ../general/parse_config.sh
	run get_config_value 'other' other_config

	assert "$output" same_as 'ovalue'
}

@test 'Load improperly formatted value' {
	load ../general/parse_config.sh
	run get_config_value 'nospace'

	assert $state equals 1
}

@test 'load nonexistent value' {
	load ../general/parse_config.sh
	run get_config_value 'bad'

	assert $state equals 1
}

@test 'load nonexistent file' {
	load ../general/parse_config.sh
	run get_config_value key badconfig

	assert $state equals 2
}
