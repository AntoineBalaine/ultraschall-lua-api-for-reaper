--[[
################################################################################
# 
# Copyright (c) 2014-2019 Ultraschall (http://ultraschall.fm)
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
]]

-------------------------------------
--- ULTRASCHALL - API - FUNCTIONS ---
-------------------------------------
---    Automation Items Module    ---
-------------------------------------

if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Functions-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "AutomationItems-Module-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string2 = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "API-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  if string=="" then string=10000 
  else 
    string=tonumber(string) 
    string=string+1
  end
  if string2=="" then string2=10000 
  else 
    string2=tonumber(string2)
    string2=string2+1
  end 
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "Functions-Build", string, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "API-Build", string2, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")  
  ultraschall={} 
  
  ultraschall.API_TempPath=reaper.GetResourcePath().."/UserPlugins/ultraschall_api/temp/"
end

function ultraschall.GetProject_AutomationItemStateChunk(projectfilename_with_path, idx, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_AutomationItemStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>string AutomationItemStateChunk = ultraschall.GetProject_AutomationItemStateChunk(string projectfilename_with_path, integer idx, optional string ProjectStateChunk)</functioncall>
  <description>
    returns the idx'th automation-item from a ProjectStateChunk.
    
    It's the entry &lt;POOLEDENV
    
    returns nil in case of an error
  </description>
  <parameters>
    string projectfilename_with_path - the projectfile+path, from which to get the automation-item-statechunk; nil to use ProjectStateChunk
    integer idx - the number of the requested automation-item from the ProjectStateChunk with 1 for the first AutomItem.
    optional string ProjectStateChunk - a statechunk of a project, usually the contents of a rpp-project-file
  </parameters>
  <retvals>
    string AutomationItemStateChunk - the statechunk of the idx'th automation-item
  </retvals>
  <chapter_context>
    Automation Items
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_AutomationItems_Module.lua</source_document>
  <tags>automationitems, get, automation, statechunk, projectstatechunk</tags>
</US_DocBloc>
]]
  -- check parameters and prepare variable ProjectStateChunk
  if projectfilename_with_path~=nil and type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_AutomationItemStateChunk","projectfilename_with_path", "Must be a string or nil(the latter when using parameter ProjectStateChunk)!", -1) return nil end
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_AutomationItemStateChunk","ProjectStateChunk", "No valid ProjectStateChunk!", -2) return nil end
  if projectfilename_with_path~=nil then
    if reaper.file_exists(projectfilename_with_path)==true then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path, false)
    else ultraschall.AddErrorMessage("GetProject_AutomationItemStateChunk","projectfilename_with_path", "File does not exist!", -3) return nil
    end
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_AutomationItemStateChunk", "projectfilename_with_path", "No valid RPP-Projectfile!", -4) return nil end
  end
  local count=0
  while ProjectStateChunk:find("  <POOLEDENV")~=nil do
    count=count+1    
    local AutomStateChunk, offset=ProjectStateChunk:match("  (<POOLEDENV.-  >)()")
    if count==idx then return AutomStateChunk end
    ProjectStateChunk=ProjectStateChunk:sub(offset,-1)
  end
  ultraschall.AddErrorMessage("GetProject_AutomationItemStateChunk", "idx", "no such automation item", -5)
  return nil
end

--A=ultraschall.ReadFullFile("c:\\automitem\\automitem.rpp")
--B=ultraschall.GetProject_AutomationItemStateChunk("C:\\rendercode-project.rpp",1,A)


function ultraschall.GetProject_CountAutomationItems(projectfilename_with_path, ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_CountAutomationItems</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.95
    Lua=5.3
  </requires>
  <functioncall>integer automation_items_count = ultraschall.GetProject_CountAutomationItems(string projectfilename_with_path, optional string ProjectStateChunk)</functioncall>
  <description>
    returns the number of automation-items available in a ProjectStateChunk.

    It's the entry &lt;POOLEDENV
                            
    returns -1 in case of an error
  </description>
  <parameters>
    string projectfilename_with_path - the projectfile+path, from which to get the automation-item-count; nil to use ProjectStateChunk
    optional string ProjectStateChunk - a statechunk of a project, usually the contents of a rpp-project-file; only used, when projectfilename_with_path=nil
  </parameters>
  <retvals>
    integer automation_items_count - the number of automation-items
  </retvals>
  <chapter_context>
    Automation Items
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_AutomationItems_Module.lua</source_document>
  <tags>automationitems, count, automation, statechunk, projectstatechunk</tags>
</US_DocBloc>
]]
  -- check parameters and prepare variable ProjectStateChunk
  if projectfilename_with_path~=nil and type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_CountAutomationItems","projectfilename_with_path", "Must be a string or nil(the latter when using parameter ProjectStateChunk)!", -1) return -1 end
  if projectfilename_with_path==nil and ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_CountAutomationItems","ProjectStateChunk", "No valid ProjectStateChunk!", -2) return -1 end
  if projectfilename_with_path~=nil then
    if reaper.file_exists(projectfilename_with_path)==true then ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path, false)
    else ultraschall.AddErrorMessage("GetProject_CountAutomationItems","projectfilename_with_path", "File does not exist!", -3) return -1
    end
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProject_CountAutomationItems", "projectfilename_with_path", "No valid RPP-Projectfile!", -4) return -1 end
  end
  
  local count=0
  while ProjectStateChunk:find("  <POOLEDENV")~=nil do
    count=count+1    
    ProjectStateChunk=ProjectStateChunk:match("  <POOLEDENV(.*)")
  end
  return count
end

function ultraschall.AutomationItems_GetAll()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AutomationItems_GetAll</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>integer number_of_automationitems, table AutomationItems_Table = ultraschall.AutomationItems_GetAll()</functioncall>
  <description>
    Returns all automation items from the current project as a handy table
    
    The format of the table is as follows:
        AutomationItems[automationitem_idx]["Track"] - the track, in which the automation item is located
        AutomationItems[automationitem_idx]["EnvelopeObject"] - the envelope, in which the automationitem is located
        AutomationItems[automationitem_idx]["EnvelopeName"] - the name of the envelope
        AutomationItems[automationitem_idx]["AutomationItem_Index"] - the index of the automation with EnvelopeObject
        AutomationItems[automationitem_idx]["AutomationItem_PoolID"] - the pool-Id of the automation item
        AutomationItems[automationitem_idx]["AutomationItem_Position"] - the position of the automation item in seconds
        AutomationItems[automationitem_idx]["AutomationItem_Length"] - the length of the automation item in seconds
        AutomationItems[automationitem_idx]["AutomationItem_Startoffset"] - the startoffset of the automation item in seconds
        AutomationItems[automationitem_idx]["AutomationItem_Playrate"]- the playrate of the automation item
        AutomationItems[automationitem_idx]["AutomationItem_Baseline"]- the baseline of the automation item, between 0 and 1
        AutomationItems[automationitem_idx]["AutomationItem_Amplitude"]- the amplitude of the automation item, between -1 and +1
        AutomationItems[automationitem_idx]["AutomationItem_LoopSource"]- the loopsource-state of the automation item; 0, unlooped; 1, looped
        AutomationItems[automationitem_idx]["AutomationItem_UISelect"]- the selection-state of the automation item; 0, unselected; nonzero, selected
        AutomationItems[automationitem_idx]["AutomationItem_Pool_QuarteNoteLength"]- the quarternote-length
  </description>
  <retvals>
    integer number_of_automationitems - the number of automation-items found in the current project
    table AutomationItems_Table - all found automation-items as a handy table(see description for details)
  </retvals>
  <chapter_context>
    Automation Items
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_AutomationItems_Module.lua</source_document>
  <tags>automation items, get all</tags>
</US_DocBloc>
--]]
  local Envelopes_Count, Envelopes=ultraschall.GetAllTrackEnvelopes(true)
  local AutomationItems={}
  local AutomationItems_Count=0
  for i=1, Envelopes_Count do
    for a=0, reaper.CountAutomationItems(Envelopes[i]["EnvelopeObject"])-1 do
       AutomationItems_Count=AutomationItems_Count+1
       AutomationItems[AutomationItems_Count]={}
       AutomationItems[AutomationItems_Count]["Track"]=Envelopes[i]["Track"]
       AutomationItems[AutomationItems_Count]["EnvelopeName"]=Envelopes[i]["EnvelopeName"]
       AutomationItems[AutomationItems_Count]["EnvelopeObject"]=Envelopes[i]["EnvelopeObject"]
       AutomationItems[AutomationItems_Count]["AutomationItem_Index"]=a
       AutomationItems[AutomationItems_Count]["AutomationItem_PoolID"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_POOL_ID", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Position"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_POSITION", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Length"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_LENGTH", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Startoffset"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_STARTOFFS", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Playrate"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_PLAYRATE", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Baseline"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_BASELINE", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Amplitude"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_AMPLITUDE", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_LoopSource"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_LOOPSRC", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_UISelect"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_UISEL", 0, false)
       AutomationItems[AutomationItems_Count]["AutomationItem_Pool_QuarteNoteLength"]=reaper.GetSetAutomationItemInfo(Envelopes[i]["EnvelopeObject"], a, "D_POOL_QNLEN", 0, false)
    end
  end
  return AutomationItems_Count, AutomationItems
end

--A,B=ultraschall.AutomationItems_GetAll()

function ultraschall.AutomationItem_Delete(TrackEnvelope, automationitem_idx, preserve_points)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AutomationItem_Delete</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.05
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.AutomationItem_Delete(TrackEnvelope env, integer automationitem_idx, optional boolean preservepoints)</functioncall>
  <description>
    Deletes an Automation-Item, optionally preserves the points who are added to the underlying envelope.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, deleting was successful; false, deleting was not successful
  </retvals>
  <parameters>
    TrackEnvelope env - the TrackEnvelope, in which the automation-item to be deleted is located
    integer automationitem_idx - the automationitem that shall be deleted; 0, for the first one
    optional boolean preservepoints - true, keep the envelopepoints and add them to the underlying envelope; nil or false, just delete the AutomationItem
  </parameters>
  <chapter_context>
    Automation Items
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_AutomationItems_Module.lua</source_document>
  <tags>automation items, delete, preserve points</tags>
</US_DocBloc>
--]]
  if ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("AutomationItem_Delete", "TrackEnvelope", "must be a valid TrackEnvelope", -1) return false end
  if math.type(automationitem_idx)~="integer" then ultraschall.AddErrorMessage("AutomationItem_Delete", "automationitem_idx", "must be an integer", -2) return false end
  if automationitem_idx<0 then ultraschall.AddErrorMessage("AutomationItem_Delete", "automationitem_idx", "must be bigger or equal 0", -3) return false end
  if reaper.CountAutomationItems(TrackEnvelope)-1<automationitem_idx then ultraschall.AddErrorMessage("AutomationItem_Delete", "automationitem_idx", "no such automationitem in TrackEnvelope", -4) return false end
  
  reaper.Undo_BeginBlock()
  
  reaper.PreventUIRefresh(1)
  visible, lane, unknown = ultraschall.GetEnvelopeState_Vis(TrackEnvelope)
  if visible==0 then 
    ultraschall.SetEnvelopeState_Vis(TrackEnvelope, 1, lane, unknown)
  end
  
  local AutomationItems_selectionstate={}
  local AutomationItems_selectioncount=0
  
  for i=1, reaper.CountAutomationItems(TrackEnvelope) do
    AutomationItems_selectionstate[i]=reaper.GetSetAutomationItemInfo(TrackEnvelope, i-1, "D_UISEL", 1, false)
    reaper.GetSetAutomationItemInfo(TrackEnvelope, i-1, "D_UISEL", 0, true)
  end
  table.remove(AutomationItems_selectionstate, automationitem_idx+1)
  
  reaper.GetSetAutomationItemInfo(TrackEnvelope, automationitem_idx, "D_UISEL", 1, true)
  
  if preserve_points==true then
    reaper.Main_OnCommand(42088,0)
  else
    reaper.Main_OnCommand(42086,0)
  end
  
  for i=1, reaper.CountAutomationItems(TrackEnvelope) do
    reaper.GetSetAutomationItemInfo(TrackEnvelope, i-1, "D_UISEL", AutomationItems_selectionstate[i], true)
  end
  
  if visible==0 then 
    visible = ultraschall.SetEnvelopeState_Vis(TrackEnvelope, 0, lane, unknown)
  end
  reaper.PreventUIRefresh(-1)  

  reaper.Undo_EndBlock("Deleted Automation Item", -1)
  return true
end


function ultraschall.AutomationItems_GetByTime(Env, position)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AutomationItems_GetByTime</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.10
    Lua=5.3
  </requires>
  <functioncall>integer found_automation_items, table automation_item_indices = ultraschall.AutomationItems_GetByTime(TrackEnvelope Env, number position)</functioncall>
  <description>
    returns all automation-items at a given position in an Envelope
    
    returns -1 in case of an error
  </description>
  <parameters>
    TrackEnvelope Env - the envelope, whose automation-items you want to get
    number position - the position in seconds from wich you want to get the automation items
  </parameters>
  <retvals>
    integer found_automation_items - the number of automation-items found; -1, in case of an error
    table automation_item_indices - the indices of the found automation-items
  </retvals>
  <chapter_context>
    Automation Items
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_AutomationItems_Module.lua</source_document>
  <tags>automationitems, get, at, position</tags>
</US_DocBloc>
]]
  if ultraschall.type(Env)~="TrackEnvelope" then ultraschall.AddErrorMessage("AutomationItems_GetByTime", "Env", "must be an Envelope", -1) return -1 end
  if type(position)~="number" then ultraschall.AddErrorMessage("AutomationItems_GetByTime", "position", "must be a number", -2) return -1 end
  local AItems={}
  local AItems_Count=0
  for i=0, reaper.CountAutomationItems(Env)-1 do
    local startposition=reaper.GetSetAutomationItemInfo(Env, i, "D_POSITION", 0, false)
    local length=reaper.GetSetAutomationItemInfo(Env, i, "D_LENGTH", 0, false)
    if position>=startposition and position<=startposition+length then
      AItems_Count=AItems_Count+1
      AItems[AItems_Count]=i
    end
  end
  return AItems_Count, AItems
end



function ultraschall.AutomationItem_Split(Env, position, index, selected)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>AutomationItem_Split</slug>
  <requires>
    Ultraschall=4.2
    Reaper=6.10
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.AutomationItem_Split(TrackEnvelope Env, number position, integer index, integer selected)</functioncall>
  <description>
    splits an automation-item at position in Env
    
    returns false in case of an error
  </description>
  <parameters>
    TrackEnvelope Env - the envelope, whose automation-item you want to split
    number position - the position in seconds at wich you want to split the automation item
    integer index - the index of the automation-item, that you want to split
    integer selected - 0, set the newly created automation item unselected
                     - 1, set it selected
                     - 2, use selection-state of the original automation-item
  </parameters>
  <retvals>
    boolean retval - true, splitting was successful; false, splitting was unsuccessful
  </retvals>
  <chapter_context>
    Automation Items
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_AutomationItems_Module.lua</source_document>
  <tags>automationitems, split, at, position</tags>
</US_DocBloc>
]]
  if ultraschall.type(Env)~="TrackEnvelope" then ultraschall.AddErrorMessage("AutomationItem_Split", "Env", "must be an Envelope", -1) return false end
  if type(position)~="number" then ultraschall.AddErrorMessage("GetAutomationItemsByTime", "position", "must be a number", -2) return false end
  if math.type(index)~="integer" then ultraschall.AddErrorMessage("GetAutomationItemsByTime", "index", "must be an integer", -3) return false end
  if index<0 or index>reaper.CountAutomationItems(Env)-1 then ultraschall.AddErrorMessage("GetAutomationItemsByTime", "index", "no such automation-item available", -4) return false end
  if math.type(selected)~="integer" then ultraschall.AddErrorMessage("GetAutomationItemsByTime", "selected", "must be an integer", -5) return false end
  if selected<0 or selected>2 then ultraschall.AddErrorMessage("GetAutomationItemsByTime", "selected", "must be 0(unselected), 1(selected) or 2(use automation-item-selectstate)", -6) return false end

  local startposition=reaper.GetSetAutomationItemInfo(Env, index, "D_POSITION", 0, false)
  local length=reaper.GetSetAutomationItemInfo(Env, index, "D_LENGTH", 0, false)
  if position<=startposition or position>=startposition+length then
    ultraschall.AddErrorMessage("GetAutomationItemsByTime", "position", "position is outside of automation-item", -7) 
    return false
  end

  index=index+1
  local Selections={}
  for i=0, reaper.CountAutomationItems(Env)-1 do
    Selections[i]=reaper.GetSetAutomationItemInfo(Env, i, "D_UISEL", 0, false)
  end
  if selected==2 then selected=Selections[index-1] end
  table.insert(Selections, index, selected)
  reaper.PreventUIRefresh(1)
  for i=0, reaper.CountAutomationItems(Env)-1 do
    if i~=index-1 then
      reaper.GetSetAutomationItemInfo(Env, i, "D_UISEL", 0, true)
    else
      reaper.GetSetAutomationItemInfo(Env, i, "D_UISEL", 1, true)
    end
  end  
  local oldpos=reaper.GetCursorPosition()
  reaper.SetEditCurPos(position, false, false)
  reaper.Main_OnCommand(42087, 0)
  reaper.SetEditCurPos(oldpos, false, false)
  for i=0, reaper.CountAutomationItems(Env)-1 do
    reaper.GetSetAutomationItemInfo(Env, i, "D_UISEL", Selections[i], true)
  end 
  reaper.PreventUIRefresh(0)
  return true
end

