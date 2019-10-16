require_relative 'event'
require_relative 'sheet_logger'
require 'google_drive'

class SheetEvent < Event
	attr_accessor :input_cell, :output_cell
	
	def initialize(sheet_key, work_sheet=0)
		# Creates a session. This will prompt the credential via command line for the
		# first time and save it to config.json file for later usages.
		# See this document to learn how to create config.json:
		# https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md
		session = GoogleDrive::Session.from_config("config.json")

		# First worksheet of
		# https://docs.google.com/spreadsheet/ccc?key=pz7XtlQC-PYx-jrVMJErTcg
		# Or https://docs.google.com/a/someone.com/spreadsheets/d/pz7XtlQC-PYx-jrVMJErTcg/edit?usp=drive_web
		@ws = session.spreadsheet_by_key(sheet_key).worksheets[work_sheet]
		@input_cell = ['A', 1]
		@output_cell = ['A', 7]
	end

	def get_input()
		sleep 1 while (read_input_cell() == "")
		#SheetLogger.log("Got INPUT")
		input = read_input_cell()
		clear_input_cell()
		return input
	end

	def read_input_cell()
		@ws.reload
		return @ws[@input_cell[1], @input_cell[0].upcase.ord-64]
	end

	def clear_input_cell()
		@ws[@input_cell[1], @input_cell[0].upcase.ord-64] = ""
		@ws.save
	end
end	