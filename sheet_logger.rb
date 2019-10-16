require 'google_drive'

class SheetLogger
	@session = GoogleDrive::Session.from_config("config.json")
	@ws = @session.spreadsheet_by_key("1Ug69qLs9DWpQTjZQCczOZ4Mx-V5T7FeAZBiop5K90PE").worksheets[0]
	@output_cell = ['A', 7]

	def self.log(message)
		@ws[@output_cell[1], @output_cell[0].upcase.ord-64] = message
		@ws.save
	end
end