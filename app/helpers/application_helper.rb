# Methods added to this helper will be available to all templates in the application.
require "open-uri"
require "nkf"
require "cgi"
require "digest/md5"
require "rexml-expansion-fix"

module ApplicationHelper
  def rgeo_img(address)
    if address
      api_uri = "http://maps.google.com/maps/geo"
      api_key = "ABQIAAAANmKytc5ypjH_KbDCAjAbphQDKhXEaOc5bfrrqKGQVNQhB2US9xS2H8rrxAlYogW8PXf5UsKofAE-_A"
      uri = "#{api_uri}?&q=#{CGI.escape(NKF.nkf("-w -m0", address))}&output=xml&key=#{api_key}"

      hash = Digest::MD5.new.update(uri).to_s
      filename = "tmp/cache/uri_" + hash # rails向け
      if File.exist?(filename)
        doc = REXML::Document.new(open(filename))
      else
        doc = REXML::Document.new(open(uri))
        open(uri) do |i|
          open(filename, "w") do |o|
            o.write(i.read)
          end
        end
      end

      case doc.elements["/kml/Response/Status/code"].text
      when "200"
        point = doc.elements["/kml/Response/Placemark/Point/coordinates"].text.split(/,/)
        image = "http://maps.google.com/staticmap?center=#{point[1]},#{point[0]}&zoom=18&size=600x200&markers=#{point[1]},#{point[0]}&key=#{api_key}"
        return image
      when "400"
        return "http://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Koe_zijaanzicht_2.JPG/120px-Ko    e_zijaanzicht_2.JPG"
      else
        return "http://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Koe_zijaanzicht_2.JPG/120px-Ko    e_zijaanzicht_2.JPG"
      end
    else
      return "http://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Koe_zijaanzicht_2.JPG/120px-Ko    e_zijaanzicht_2.JPG"
    end
  end

end
