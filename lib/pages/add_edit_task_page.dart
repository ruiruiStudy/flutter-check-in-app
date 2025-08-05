import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddEditTaskPage extends StatefulWidget {
  final Task? task; // 如果是编辑模式，则传入任务

  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // 编辑模式，填充现有数据
      _nameController.text = widget.task!.name;
      _noteController.text = widget.task!.note ?? '';
      _startDate = widget.task!.startDate;
      _endDate = widget.task!.endDate;
    } else {
      // 新增模式，设置默认开始日期为今天
      _startDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: isStartDate
          ? DateTime(2020) // 允许选择较早的日期作为开始日期
          : (_startDate ?? DateTime.now()), // 结束日期仍需不早于开始日期
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('zh', 'CN'), // 显式指定中文本地化
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // 如果结束日期早于开始日期，则更新结束日期
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择开始和结束日期')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('结束日期不能早于开始日期')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      final task = Task(
        id: widget.task?.id ?? taskProvider.generateTaskId(),
        name: _nameController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        checkInDates: widget.task?.checkInDates ?? [],
        createdAt: widget.task?.createdAt ?? DateTime.now(),
      );

      if (widget.task != null) {
        await taskProvider.updateTask(task);
      } else {
        await taskProvider.addTask(task);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.task != null ? '任务更新成功' : '任务创建成功'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? '编辑任务' : '新增任务'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 任务名称
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '任务名称',
                hintText: '请输入任务名称',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              enableIMEPersonalizedLearning: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入任务名称抖音打卡14天领10.8元';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 开始日期
            InkWell(
              onTap: () => _selectDate(context, true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '开始日期',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _startDate != null
                      ? DateFormat('yyyy年MM月dd日').format(_startDate!)
                      : '请选择开始日期',
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 结束日期
            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '结束日期',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _endDate != null
                      ? DateFormat('yyyy年MM月dd日').format(_endDate!)
                      : '请选择结束日期',
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 备注
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                hintText: '请输入备注信息',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: 3,
              enableIMEPersonalizedLearning: true,
            ),
            const SizedBox(height: 32),
            
            // 保存按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.task != null ? '更新' : '保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 