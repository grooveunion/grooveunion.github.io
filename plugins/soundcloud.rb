require 'json'
require 'net/http'


module Jekyll
    class SoundCloud < Liquid::Tag
        def initialize(tag_name, markup, tokens)
            #check if an url is given as argument => if yes the new method is used
            if /^http/ =~ markup
                #parsing the "new" way with only pasing the url of the ressource
                if /(?<url>[a-z0-9\/\-\:\.]+)(?:\s+(?<options>.*))?/ =~ markup
                    info = retrieve_info(url)
                    @type  = info['kind'] + 's'
                    @id    = info['id']
                    @options = ([] unless options) || options.split(" ")
                end
                else
                puts "no match"
                #parsing the "old" way with type and id
                if /(?<type>\w+)\s+(?<id>\d+)(?:\s+(?<options>.*))?/ =~ markup
                    @type  = type
                    @id    = id
                    @options = ([] unless options) || options.split(" ")
                end
            end
            
            @markup = markup
        end
        
        def retrieve_info(path)
            response = Net::HTTP.get_response("api.soundcloud.com","/resolve.json?client_id=YOUR_CLIENT_ID&url=" + path)
            case response
                when Net::HTTPRedirection then
                location = response['location']
                response = Net::HTTP.get_response(URI(location))
            end
            json = JSON.parse response.body
            return json
        end
        
        def render(context)
            if @type and @id
                @height = (450 unless @type == 'tracks') || 166
                @resource = (@type unless @type === 'favorites') || 'users'
                @extra = ("" unless @type === 'favorites') || '%2Ffavorites'
                @joined_options = @options.join("&amp;")
                "<iframe width=\"100%\" height=\"#{@height}\" scrolling=\"no\" frameborder=\"no\" src=\"http://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2F#{@resource}%2F#{@id}#{@extra}&amp;#{@joined_options}\"></iframe>"
                else
                "Error processing input, expected syntax: {% soundcloud type id [options...] %} received: #{@markup}"
            end
        end
    end
end

Liquid::Template.register_tag('soundcloud', Jekyll::SoundCloud)
