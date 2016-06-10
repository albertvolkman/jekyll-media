
Jekyll::Hooks.register(:site, :post_write) do |site|
  mr = MediaReport.new(site)
end
