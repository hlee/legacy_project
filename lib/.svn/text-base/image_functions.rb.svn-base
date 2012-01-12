require "errors"
module ImageFunctions

   def dataround(val)
      return (val*1000).round/1000.0
   end

   def write_image(attribute, data)
      if data.nil?
         write_attribute(attribute,"")
      else
         data.compact!
         write_attribute(attribute,data.pack("e*"))
      end
   end
   def read_image(attribute)
      image=read_attribute(attribute)
      if image.nil?
         return nil
      else
         return read_attribute(attribute).unpack("e*")
      end
   end
   def max(x,y)
      return (x>y ? x : y)
   end
   def min(x,y)
      return (x<y ? x : y)
   end
   def smallest_image(data1, data2)
      return data2 if data1.nil?
      return data1 if data2.nil?
      result=[]
      data1.each_index { |idx|
         result[idx]=data2[idx] if data1[idx].nil?
         result[idx]=data1[idx] if data2[idx].nil?
         if data2[idx]>data1[idx]
            result[idx]=data1[idx] 
         else
            result[idx]=data2[idx] 
         end
      }
      return result
   end
   def largest_image(data1, data2)
      return data2 if data1.nil?
      return data1 if data2.nil?
      result=[]
      data1.each_index { |idx|
         result[idx]=data2[idx] if data1[idx].nil?
         result[idx]=data1[idx] if data2[idx].nil?
         if data2[idx]>data1[idx]
            result[idx]=data2[idx] 
         else
            result[idx]=data1[idx] 
         end
      }
      return result
   end
   def total_image(data1, data2)
      return data2 if data1.nil?
      return data1 if data2.nil?
      result=[]
      data1.each_index { |idx|
         result[idx]=data2[idx] if data1[idx].nil?
         result[idx]=data1[idx] if data2[idx].nil?
         result[idx]=data1[idx] +data2[idx]
      }
      return result
   end
   def image_division(data1, divisor)
      return nil if data1.nil?
      result=[]
      result=data1.collect{ |val| val/divisor }
      return result
   end
   def diff_image(data1, data2)
      return data1 if data2.nil?
      result=[]
      if data1.nil?
         result=data2.collect {|val| val*-1}
      else
         data1.each_index { |idx|
            if data1[idx].nil?
               result[idx]=-1*data2[idx] 
            elsif data2[idx].nil?
               result[idx]=data1[idx] 
            else
               result[idx]=data1[idx]  - data2[idx]
            end
         }
      end
      return result
   end
   def power_image(data1, power)
      return nil if data1.nil?
      result=[]
      result=data1.collect{ |val| (val.nil? ? 0 : val ) ** power }
      return result
   end
def calc_idx(src_start,src_stop,intvl, search_frequency, dup_edge=true)
   if dup_edge == false
   
     if search_frequency > src_stop
       return nil
     end
     if search_frequency < src_start
       return nil
     end
   end
   max_pos=((src_stop-src_start)/intvl).to_i
   pos=(search_frequency-src_start).to_f/intvl.to_f
   if pos.floor < 0
      floor=0
      ceil=0
   elsif pos.ceil > max_pos
      floor=max_pos
      ceil=max_pos
   else
      floor=pos.floor
      ceil=pos.ceil
   end
   pre_wgt=(pos-ceil).abs
   #puts "#{floor}-#{ceil}~#{pre_wgt} #{pre_wgt},#{post_wgt}"
   return { 
      :pre_index=>floor, 
      :post_index=>ceil, 
      :pre_wgt=>pre_wgt, 
   }
end
#
# map_data
# Takes an array of data with a start frequency and stop frequency and generates a new array that has
# a new start and stop frequency along with the number of elements being sample_count
def map_data(src_start,src_stop,dest_start,dest_stop,src_array,sample_count, default_val=nil)
   raise("Source Array is a #{src_array.class()}") if !src_array.instance_of?(Array)
   src_array_type=0 #1-array 2-numbers
   src_intvl=0
   src_array.each { |element|
      if (element.kind_of?(Array))
         raise('All elements not of same type') if src_array_type==2
         src_array_type=1
         src_intvl =(src_stop-src_start).to_f/(src_array[0].length()-1).to_f
      elsif (element.kind_of?(Numeric))
         raise('All elements not of same type') if src_array_type==1
         src_array_type=2
         src_intvl =(src_stop-src_start).to_f/(src_array.length()-1).to_f
      else
         raise('Illegal type')
      end

   }
   dest_intvl=(dest_stop-dest_start).to_f/(sample_count-1).to_f
   transformed=[]
   if dest_intvl < 1
     raise SunriseError.new("Destination interval is zero., Target stop Freq is #{dest_stop} and Target start frequency #{dest_start} and sample count is #{sample_count}, Interval is #{dest_intvl}")
   end
   dest_start.step(dest_stop,dest_intvl) { |freq|
      translation=calc_idx(src_start,src_stop,src_intvl,freq, dup_edge=default_val.nil?)
      val=0
      if (src_array_type==2)
         if (!translation.nil?)
            val=src_array[translation[:pre_index]] *
               translation[:pre_wgt] + 
               src_array[translation[:post_index]] *
               (1-translation[:pre_wgt])
         else
            val=default_val
         end
         transformed.push(dataround(val))
       elsif (src_array_type==1)
         src_array.each_index { |src_index|
            if (transformed[src_index].nil?)
               transformed[src_index]=[]
            end
            if (!translation.nil?)
               val=src_array[src_index][translation[:pre_index]] *
                  translation[:pre_wgt] +
                  src_array[src_index][translation[:post_index]] *
                  (1-translation[:pre_wgt])
            else
               val=default_val
            end
            transformed[src_index].push(dataround(val))
         }
      else
         raise("Unrecognized src_array type")
      end
   }
   return transformed
end

end
