import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class WordCount {

    public static class TokenizerMapper
            extends Mapper<Object, Text, Text, IntWritable>{

        private final static IntWritable one = new IntWritable(1);
        private Text word = new Text();

        public void map(Object key, Text value, Context context
        ) throws IOException, InterruptedException {
            StringTokenizer itr = new StringTokenizer(value.toString());
            while (itr.hasMoreTokens()) {
                word.set(itr.nextToken());
                context.write(word, one);
            }
        }
    }

    public static class IntSumReducer
            extends Reducer<Text,IntWritable,Text,IntWritable> {
        private IntWritable result = new IntWritable();

        public void reduce(Text key, Iterable<IntWritable> values,
                           Context context
        ) throws IOException, InterruptedException {
            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result);
        }
    }

    public class ToolMapReduce extends Configured implements Tool {

        public static void main(String[] args) throws Exception {
            int res = ToolRunner.run(new Configuration(), new ToolMapReduce(), args);
            System.exit(res);
        }

        @Override
        public int run(String[] args) throws Exception {

            // When implementing tool
            Configuration conf = this.getConf();

            // Create job
            Job job = new Job(conf, "Tool Job");
            job.setJarByClass(ToolMapReduce.class);

            // Setup MapReduce job
            // Do not specify the number of Reducer
            job.setMapperClass(Mapper.class);
            job.setReducerClass(Reducer.class);

            // Specify key / value
            job.setOutputKeyClass(LongWritable.class);
            job.setOutputValueClass(Text.class);

            // Input
            FileInputFormat.addInputPath(job, new Path(args[0]));
            job.setInputFormatClass(TextInputFormat.class);

            // Output
            FileOutputFormat.setOutputPath(job, new Path(args[1]));
            job.setOutputFormatClass(TextOutputFormat.class);

            // Execute job and return status
            return job.waitForCompletion(true) ? 0 : 1;
        }
    }
}