<script language="vbscript" runat="server">
Function bytes2string(data)
        If (vartype(data) = 8) Then data = string2bytes(data)
        Const adLongVarChar = 201
        Dim rs
        Set rs = Server.CreateObject("ADODB.Recordset")
        If (LenB(data) > 0) Then
                rs.Fields.Append "data", adLongVarChar, LenB(data)
                rs.Open()
                rs.AddNew()
                rs.Fields("data").AppendChunk(data)
                rs.Update()
                binary2string = rs.Fields("data")
                rs.Close()
                Set rs = Nothing
        Else
                binary2string = ""
        End If
End Function

Function string2bytes(ByRef data)
        Const adLongVarBinary = 205
        Dim rs
        Set rs = Server.CreateObject("ADODB.Recordset")
        If (LenB(data) > 0) Then
                rs.Fields.Append "data", adLongVarBinary, LenB(data)
                rs.Open()
                rs.AddNew()
                rs.Fields("data").AppendChunk(data & ChrB(0))
                rs.Update()
                string2bytes = rs.Fields("data").GetChunk(LenB(data))
                rs.Close()
                Set rs = Nothing
        Else
                string2bytes = ""
        End If
End Function

Function bytes2file(ByRef data, filename)
        Const adTypeBinary = 1
        Const adSaveCreateOverwrite = 2
        Const adModeReadWrite = 3
        Dim st
        Set st = Server.CreateObject("ADODB.Stream")
        st.Type = adTypeBinary
        Call st.Open()
        If (Typename(data) = "Byte()") Then
                Call st.Write(data)
        Else
                Call st.Write(string2bytes(data))
        End If
        Call st.SaveToFile(filename, adSaveCreateOverWrite)
        Call st.Close()
End Function


Function f_lenB(ByRef data)
    f_lenB = LenB(data)
End Function
</script>
