<?php

$curr_path=getcwd();
$lib_path=$curr_path . "/lib";
$download_path=$curr_path . "/download";
$report_path=$curr_path . "/report";

$cmd="json2csv.sh";
$param="";

$source_path="--source_path " . $download_path;
$desc_path="--desc_path " . $report_path;
$source_file="--source_file report.json";

$desc_file_name="report.csv";
$desc_file="--desc_file " . $desc_file_name;

$count_date_range=30;
$date_range="--date_range $count_date_range";

$purge="--purge 1";

$merge_path="--merge_path $report_path";
$merge_file1="report.csv";
$merge_file2="report2.csv";

$merge_file_output="--merge_file_output $report_path";

//parameter list
$param_list = array(
        "source_path", 
        "desc_path",
        "source_file",
        "desc_file_name",
        "desc_file",
        "count_date_range",
        "date_range",
        "purge",
        "merge_path",
        "merge_file1",
        "merge_file2",
        "merge_file_output");

//check post value
for ($i=0;$i<count($param_list);$i++)
{
  if (isset($_POST[$param_list[$i]])) {
    if ($_POST[$param_list[$i]] != "") {
      $$param_list[$i]=$_POST[$param_list[$i]];
    }
  }
}


//command list
$command_list = array(
	"Convert json to csv"=>"$lib_path/$cmd $source_path $source_file $desc_path $desc_file $date_range",
        "Merge csv"=>"$lib_path/$cmd $merge_path $merge_file1 $merge_file1 $merge_file_output $desc_path $desc_file",
	"Delete all files"=>"$lib_path/$cmd $purge $source_path $desc_path"
);

if (isset($_POST['group1'])) {
  echo "choose = " . $command_list[$_POST['group1']];
  $run = "bash " . $command_list[$_POST['group1']];
  echo "Will run cmd = " . $run;
  $output = shell_exec($run);
  echo "<br>Result : " . $output . "<br>";
}


?>

<form action="index.php" method="post">
<?php
    for ($i=0;$i<count($command_list);$i++)
    {
      echo '<input type="radio" name="group1" value="' . key($command_list) . '"> ' . key($command_list) . '<br>Command: ' . current($command_list) . '<br>';
      next($command_list);
    }

    for ($i=0;$i<count($param_list);$i++)
    {
      echo '<p>' . $param_list[$i] . ': <input type="text" name="' . $param_list[$i] . '" value="' . $$param_list[$i] . '"/> ';
    }
?>
    <p><input type="submit" /></p>
</form>
