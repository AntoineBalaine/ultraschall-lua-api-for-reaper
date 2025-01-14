  --[[
  ################################################################################
  # 
  # Copyright (c) 2014-2022 Ultraschall (http://ultraschall.fm)
  # 
  # Permission is hereby granted, free of charge, to any person obtaining a copy
  # of this software and associated documentation files (the "Software"), to deal
  # in the Software without restriction, including without limitation the rights
  # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  # copies of the Software, and to permit persons to whom the Software is
  # furnished to do so, subject to the following conditions:
  # 
  # The above copyright notice and this permission notice shall be included in
  # all copies or substantial portions of the Software.
  # 
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  # THE SOFTWARE.
  # 
  ################################################################################
  --]]
  
dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
reaper.ClearConsole()

A=ultraschall.ReadFullFile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api/DocsSourcefiles/reaper-apidocs.USDocML")
--B=FromClip()
Filename="d:/Users/Meo-Ada Mespotine/AppData/Local/Temp/reascripthelp.html"
B=ultraschall.ReadFullFile(Filename)
B=B:match("</table></code>\n<br><br>(.*)")
Func={}


-- check for duplicate functions in Reaper-API USDocML
for k in string.gmatch(A, "<slug>(.-)</slug>") do
  kk=k:match("(.-)%(")
  if kk==nil then kk=k end
  if Func[kk]~=nil then print("<slug>"..kk.."</slug>") end
  Func[kk]=kk
end

-- check for missing functions in Reaper-API USDocML from reascript.html in temp
for k in string.gmatch(B, "<a name=\"(.-)\"><hr></a><br>") do
  if Func[k]==nil then 
    print(k)
  end
end

