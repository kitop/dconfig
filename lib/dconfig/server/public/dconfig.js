$(function(){
  var row_template =  "<tr>" +
                        "<td> <input type='text' name='new[%COUNTER%][key]' placeholder='key' /> </td>" +
                        "<td> <input type='text' name='new[%COUNTER%][value]' placeholder='value' /> </td>" + 
                        "<td class='remove'> <span class='inline-remove'>X</span> </td>" +
                      "</tr>",
      template_counter = 1,
      tbody = $("tbody", "#values");

  $("#add-new").click(function(e){
    e.preventDefault();
    tbody.append(row_template.replace(/%COUNTER%/g, template_counter));
    template_counter += 1;
  })

  tbody.on('click', '.inline-remove', function(){
    $(this).closest("tr").remove();
  })
})
