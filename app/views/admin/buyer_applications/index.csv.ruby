csv_builder = lambda do |csv|
  csv << ['ID', 'Buyer name', 'Email', 'Organisation', 'Status']

  search.results.each do |result|
    csv << [
      result.id,
      result.buyer.name,
      result.user.email,
      result.buyer.organisation,
      result.state,
    ]
  end
end

CSV.generate(&csv_builder)
