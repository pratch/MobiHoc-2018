require 'google_drive'
require 'fileutils'
require 'time'
require 'net/http'

module Jekyll
  class ProgramAtGlance < Generator
    def generate(site)
      if site.config['program-at-glance'] == nil
        return Jekyll.logger.warn "Program-at-glance data not generated, because 'program-at-glance' is not defined in _config.yml"
      end

      # Re-using sass-cache directory that suppose to be ignored from file watching and is cleaned with `jekyll clean`
      cacheDir = "#{site.source}/.sass-cache"
      if not File.directory? cacheDir
        FileUtils::mkdir_p cacheDir
      end

      if site.config['program-at-glance']['google_client_id'] == nil
        return Jekyll.logger.warn "Conference program-at-glance not generated, because 'program-at-glance.google_client_id' is not defined in _config.yml"
      end

      if site.config['program-at-glance']['spreadsheet'] == nil
        return Jekyll.logger.warn "Conference program-at-glance not generated, because 'program-at-glance.spreadsheet' is not defined in _config.yml"
      end

      begin
        session = GoogleDrive::Session.from_config(site.config['program-at-glance']['google_client_id'])
        Jekyll.logger.info 'Generating conference program-at-glance data from Google spreadsheets...'
        site.data['program-at-glance'] = {}

        for sheetKey in site.config['program-at-glance']['spreadsheet']
          begin
            Jekyll.logger.warn 'Getting data from Google Spreadsheet ', sheetKey
            spreadsheet = session.spreadsheet_by_key(sheetKey)

            for ws in spreadsheet.worksheets
              file = "#{cacheDir}/program-at-glance-#{ws.title}-#{sheetKey}"
              fileMeta = "#{cacheDir}/program-at-glance-#{ws.title}-#{sheetKey}.meta"

              if File.exist?("#{file}.pdf") and File.exist?("#{file}.png") and File.exist?(fileMeta)
                updated = Time.parse(File.read(fileMeta))
                if ws.updated.to_i <= updated.to_i
                  Jekyll.logger.info "Using cached version of ", file
                  # todo
                  next
                end
              end

              Jekyll.logger.warn 'Processing ', ws.title
              begin
                Net::HTTP.start("docs.google.com", :use_ssl => true) do |http|
                  
                  # http.get gets Temporary Redirect error instead of the PDF (not sure how to fix)

                  # resp = http.get("/spreadsheets/d/#{sheetKey}/export?format=pdf")
                  # Jekyll.logger.warn 'WH', resp
                  # open("#{file}.pdf", "wb") do |out|
                  #   out.write(resp.body)
                  # end
                  system("pdfcrop #{file}.pdf #{file}.pdf")
                  system("convert -trim -density 200 #{file}.pdf #{file}.png")

                  width = %x[pdfinfo "#{file}.pdf" | grep "Page size" | awk '{print $3}'].to_i
                  height = %x[pdfinfo "#{file}.pdf" | grep "Page size" | awk '{print $5}'].to_i

                  system("gs -o #{file}-tmp.pdf -sDEVICE=pdfwrite -dDEVICEWIDTHPOINTS=#{width * 2} -dDEVICEHEIGHTPOINTS=#{height * 2} -dPDFFitPage #{file}.pdf")
                  system("rm #{file}.pdf && mv #{file}-tmp.pdf #{file}.pdf")
                end
                File.write fileMeta, ws.updated
              rescue
                Jekyll.logger.warn "Error processing worksheet: ", $!
              end
            end
          rescue
            Jekyll.logger.warn "Error processing spreadsheet: ", $!
          end
        end
      rescue
        # return Jekyll.logger.error "Failed to generate the conference program-at-glance: ", $!
      end
    end
  end
end
