json.draw @draw
json.recordsTotal @sample.analisies.count
json.recordsFiltered  @sample.analisies.count
json.data do
  json.partial! 'analisies/analisy', collection: @sample.analisies, as: :analisy
end
