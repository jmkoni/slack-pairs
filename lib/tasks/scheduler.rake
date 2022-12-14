# Runs create groups job
task create_groups: :environment do
  CreateGroupsJob.perform
end
