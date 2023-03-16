namespace :scrape do
    task scrape_link: :environment do
        require 'nokogiri'
        require 'open-uri'

        # Fetch and parse HTML document
        doc = Nokogiri::HTML(URI.open('https://magicpin.in/Hyderabad/Miyapur/Restaurant/Chef-Bakers/store/55b016/delivery/'))
        # puts doc.inspect
        # return
        # Search for nodes by css
        # doc.css('class="catalogItemsHolder"').each do |link|
        # puts link.content
        # end

        # Search for nodes by xpath
        # puts doc.css('.itemInfo').lazy.map(&:text).map(&:strip).to_a 

        
        doc.xpath("//*[@class=\'catalogItemsHolder\']").each do |link|
        # puts link.content
        puts "========="
        link.xpath("//article").each do |link1|
            link1.xpath("//h4").each do |link2|
            #  puts link2.inspect;
            #  return
            end
            puts link1.css('.itemInfo').content 

            # link1.xpath("div").each do |link2|
            #     puts link2 ;
            #     # return
            # end
            return

        end
        puts "========="
        end

        # Or mix and match
        # doc.search('nav ul.menu li a', '//article//h2').each do |link|
        # puts link.content
        # end
    end
end
