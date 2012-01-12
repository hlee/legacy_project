class ProfileController < ApplicationController

  def index
  end

  def new
  end

  def edit
  end

  def delete
  end

  def _build_image(stdev)
    dl=Datalog.find(:all)
    avg=[]
    cnt=0.0
    dl.each { |log|
      cnt+=1.0
      log.length.times { |index|
        if cnt ==0.0
          avg[index]=0.0
        end
        avg[index]=(avg[index]* (cnt-1) + log[index])/cnt
      }
    }
    return avg
  end
end
