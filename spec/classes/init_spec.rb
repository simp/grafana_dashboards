require 'json'

Dir.glob('./src/*.json') do |json_file|
# We could set a variable for the parsed JSON, but that causes the failures to be misleading
#json = JSON.parse(File.read(json_file))

  describe "simp_grafana_dashboards #{json_file}" do
    it "should fail if the file isn't valid json" do
      begin
        JSON.parse(File.read("#{json_file}"))
      rescue JSON::ParserError
        raise ArgumentError , "Invalid JSON string for content"
      end
    end

    it "should have a SIMP tag" do
      expect(JSON.parse(File.read(json_file))['tags']).to include("simp")
    end 

    it "should populate template values with dashboard reload" do
      # We only need to run this check if templating is populated
      if JSON.parse(File.read(json_file))['templating']['list'] != []
        expect(JSON.parse(File.read(json_file))['templating']['list'][0]['refresh']).to_not eq 0
      end
    end 

    it "should have all data sources set to null" do
      File.open("#{json_file}", 'r').each_line do |line|
        expect("#{line}").to include("null") if line.match(/"datasource":/)
      end
    end
  end
end
