require 'net/http'
require 'uri'
require 'json'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class PdfGeneratorController < ApplicationController
  before_action :validate_key
  def application
    nationalid = params[:nationalid]
    p = {id: nationalid, 'api-client' => Rails.configuration.x.core_key}
    x = Net::HTTP.post_form(URI.parse(Rails.configuration.x.core_server + '/get/applicantinfo'), p)
    @applicant = JSON.parse(x.body)
    p = {id: @applicant['address'], 'api-client' => Rails.configuration.x.core_key}
    x = Net::HTTP.post_form(URI.parse(Rails.configuration.x.core_server + '/get/address'), p)
    @address = JSON.parse(x.body)
    x = Net::HTTP.get(URI.parse(Rails.configuration.x.core_server + '/get/plans'))
    @plan = JSON.parse(x).find {|p| p['planid'] == @applicant['plan_id']}
    @major = get_major @plan
    unless @major
      @majors = @applicant['major_select'].split ','
    end
    x = Net::HTTP.get(URI.parse(Rails.configuration.x.core_server + '/get/applydays'))
    @day = JSON.parse(x).find {|d| d['day'] == @applicant['applyday']}
    barcode = Barby::Code128.new(@applicant['nationalid'])
    outputter = Barby::PngOutputter.new(barcode)
    outputter.height = 125
    outputter.xdim = 3
    blob = outputter.to_png
    File.open(Rails.root.join('tmp', @applicant['nationalid'] + '.png'), 'w') {|f| f.write blob}
    @quotatypes = ['', 'คณิตศาสตร์', 'วิทยาศาสตร์', 'คอมพิวเตอร์', 'เทนนิส', 'ว่ายน้ำ', 'กอล์ฟ', 'ยิงปืน', 'เทเบิลเทนนิส', 'เทควันโด', 'ยิมนาสติกลีลา', 'แบดมินตัน', 'ฟุตบอล', 'บาสเกตบอล', 'วอลเล่ย์บอล(ชาย)', 'นาฏศิลป์', 'ศิลปะ', 'ดนตรีไทย-ขลุ่ยเพียงออ', 'ดนตรีไทย-ขับร้องเพลงไทยเดิม', 'ดนตรีไทย-ขิม', 'ดนตรีไทย-เครื่องหนัง', 'ดนตรีไทย-ฆ้องวงใหญ่', 'ดนตรีไทย-จะเข้', 'ดนตรีไทย-ซอด้วง', 'ดนตรีไทย-ซอสามสาย', 'ดนตรีไทย-ซออู้', 'ดนตรีไทย-ระนาดทุ้ม', 'ดนตรีไทย-ระนาดเอก', 'ดนตรีสากล-กีตาร์ไฟฟ้า', 'ดนตรีสากล-กีตาร์เบสไฟฟ้า', 'ดนตรีสากล-คีย์บอร์ด', 'ดนตรีสากล-กลองชุด', 'ดนตรีสากล-ขับร้องเพลงไทยสากล', 'ดุริยางค์-Alto Saxophone', 'ดุริยางค์-Clarinet', 'ดุริยางค์-Flute', 'ดุริยางค์-French Horn', 'ดุริยางค์-Oboe', 'ดุริยางค์-Percussion', 'ดุริยางค์-Piccolo', 'ดุริยางค์-Tenor Saxophone', 'ดุริยางค์-Trombone', 'ดุริยางค์-Trumpet', 'ดุริยางค์-Tuba', 'ดุริยางค์-อื่นๆ']
    render
  end

  private
  def validate_key
    return true
    if ApiKey.find_by(key: params[:api_key]).nil?
      @message = 'No API key found, the access is denied.'
      render 'fail'
      return false
    end
  end

  def get_major(plan)
    if plan['planid'] == '5'
      false
    else
      if plan['planid'] == '4'
        'การบริหารจัดการ'
      else
        'คุณภาพชีวิต'
      end
    end
  end
end
