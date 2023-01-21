# Create a scratch org and make it the default scratch org
sfdx force:org:create --setalias="apex-test-data-builder" --durationdays=7 --definitionfile=./config/project-scratch-def.json --nonamespace --setdefaultusername
