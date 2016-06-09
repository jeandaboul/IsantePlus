<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>

<%@ include file="template/localHeader.jsp"%>
<!-- taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> -->

<center>
	<table border="1">
		<tr>
			<th>Nom</th>
			<th>Description</th>
		</tr>
		<c:forEach var="vacc" items="${listVaccType}">
                <tr>
                    <td>${vacc.name}</td>
                    <td>${vacc.description}</td>        
                </tr>
         </c:forEach>             
     </table>

</center>
<%@ include file="/WEB-INF/template/footer.jsp"%>