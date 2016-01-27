module VideosHelper
  def to_megabyte(size)
    mb = size / 1.megabyte
    "#{mb.round} MB"
  end

  def pp_file_timestamp(time)
    time.strftime("%y/%m/%d %H:%M:%S")
  end

  def to_hms(sec)
    h = sec / 1.hour
    m = sec % 1.hour / 1.minutes
    s = sec % 1.hour % 1.minutes
    if h.zero?
      "#{pad0(m)}:#{pad0(s)}"
    else
      "#{h}:#{pad0(m)}:#{pad0(s)}"

    end
  end

  private
  def pad0(s)
    s.to_s.rjust(2, "0")
  end
end
