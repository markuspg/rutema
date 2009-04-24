<specification name="TR001">
<title>Rutema self hosting test</title>
<description>Test that rutemax is usable as a step in a specification using the distro test example</description>
<scenario>
	<command cmd="rutemax -c distro_test/config/minimal.rutema"/>
	<command cmd="rutemax -c distro_test/config/database.rutema"/>
	<command cmd="rutemax -c distro_test/config/database.rutema distro_test/specs/T001.spec"/>
	<command cmd="rutemax -c distro_test/config/full.rutema"/>
</scenario>
</specification>