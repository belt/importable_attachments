Configuration.path = '../../config/features'

# load feature configurations
features = Configuration.path.collect { |path| Dir.glob(File.join(path, '**')) }.flatten
features.each do |feature|
  Configuration.load feature
end
