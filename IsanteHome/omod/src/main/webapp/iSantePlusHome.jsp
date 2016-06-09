<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>

<%@ include file="template/localHeader.jsp"%>

<div align="left">
	<table border="1">
		<tr>
			<th>Etablissement</th>
			<th>Version</th>
			<th>Serveur Local</th>
			<th>Date de saisie la plus recente</th>
		</tr>
		<c:forEach var="location" items="${locationList}">
                <tr>
                    <td>${location.name}</td>
                    <td>${project.version}</td>
                    <td></td>
                    <td></td>        
                </tr>
         </c:forEach>             
     </table>
</div>


<%@ include file="/WEB-INF/template/footer.jsp"%>