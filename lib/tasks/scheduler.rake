task create_pairs: :environment do
  CreatePairsJob.perform
end
