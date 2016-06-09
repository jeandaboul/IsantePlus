<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>

<%@ include file="template/localHeader.jsp"%>

<form method="GET">
Choose a Location :<openmrs_tag:locationField formFieldName="locationId"/>
<input type="submit" value="View"/>
</form>
</hr>
<table>
	<tr>
		<td>Location ID</td>
		<td>${location.locationId}</td>
	</tr>
	<tr>
		<td>Location Name</td>
		<td>${location.name}</td>
	</tr>
</table>	

<%@ include file="/WEB-INF/template/footer.jsp"%>