import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codeacademy/domain/model/forum.dart';
import 'package:codeacademy/presentation/providers/catalog_provider.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class ForumScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const ForumScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  DiscussionForum? _activeForum;
  ForumPost? _activePost;
  
  final _postTitleController = TextEditingController();
  final _postContentController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
      await catalogProvider.loadForums(widget.courseId);
      if (catalogProvider.forums.isNotEmpty) {
        _activeForum = catalogProvider.forums.first;
        await catalogProvider.loadForumPosts(_activeForum!.id);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _postTitleController.dispose();
    _postContentController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _createForumForCourse() async {
    final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
    final success = await catalogProvider.createForum(
      widget.courseId,
      'Foro General - ${widget.courseTitle}',
      'Espacio de discusión para el curso ${widget.courseTitle}',
    );
    if (success && mounted) {
      if (catalogProvider.forums.isNotEmpty) {
        _activeForum = catalogProvider.forums.first;
        await catalogProvider.loadForumPosts(_activeForum!.id);
      }
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Foro creado con éxito!'), backgroundColor: AppColors.success),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(catalogProvider.errorMessage ?? 'Error al crear foro'), backgroundColor: AppColors.error),
      );
    }
  }

  void _createPost() async {
    if (_activeForum == null) return;
    final title = _postTitleController.text.trim();
    final content = _postContentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
    final success = await catalogProvider.createForumPost(_activeForum!.id, title, content);
    
    if (success && mounted) {
      _postTitleController.clear();
      _postContentController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tema de discusión creado'), backgroundColor: AppColors.success),
      );
    }
  }

  void _createComment() async {
    if (_activePost == null) return;
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
    final success = await catalogProvider.createForumComment(_activePost!.id, content);
    
    if (success && mounted) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario publicado'), backgroundColor: AppColors.success),
      );
    }
  }

  void _showNewPostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Tema de Discusión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _postTitleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _postContentController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Mensaje / Pregunta'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: _createPost,
            child: const Text('PUBLICAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final canCreateForum = authProvider.isTeacher || authProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(_activePost != null ? 'Comentarios' : 'Foro: ${widget.courseTitle}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_activePost != null) {
              setState(() {
                _activePost = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: LoadingOverlay(
        isLoading: catalogProvider.isLoading,
        child: _activeForum == null
            ? _buildNoForumView(canCreateForum)
            : _activePost != null
                ? _buildCommentsView(catalogProvider)
                : _buildPostsView(catalogProvider, authProvider),
      ),
    );
  }

  Widget _buildNoForumView(bool canCreateForum) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 80, color: AppColors.textMuted),
            const SizedBox(height: 20),
            const Text(
              'No hay foros disponibles para este curso.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            if (canCreateForum) ...[
              const SizedBox(height: 24),
              const Text(
                'Como docente puedes crear el foro de discusión para que tus estudiantes participen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _createForumForCourse,
                icon: const Icon(Icons.add_comment_outlined),
                label: const Text('CREAR FORO DEL CURSO'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(260, 50)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPostsView(CatalogProvider catalogProvider, AuthProvider authProvider) {
    return Column(
      children: [
        Expanded(
          child: catalogProvider.posts.isEmpty
              ? const Center(child: Text('No hay discusiones creadas aún. ¡Sé el primero!', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: catalogProvider.posts.length,
                  itemBuilder: (context, index) {
                    final post = catalogProvider.posts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        subtitle: Text(
                          'Por: ${post.authorEmail ?? 'Usuario'}\n${post.content}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(Icons.forum_outlined, color: AppColors.primaryLight),
                        onTap: () async {
                          setState(() {
                            _activePost = post;
                          });
                          await catalogProvider.loadForumComments(post.id);
                        },
                      ),
                    );
                  },
                ),
        ),
        if (authProvider.isAuthenticated)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _showNewPostDialog,
              icon: const Icon(Icons.add),
              label: const Text('NUEVO TEMA DE DISCUSIÓN'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentsView(CatalogProvider catalogProvider) {
    return Column(
      children: [
        // Main Post content
        Container(
          padding: const EdgeInsets.all(20),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_activePost!.title, style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                'Preguntado por: ${_activePost!.authorEmail ?? "Usuario"}',
                style: AppTextStyles.caption,
              ),
              const Divider(height: 24, color: AppColors.surfaceLight),
              Text(_activePost!.content, style: AppTextStyles.body),
            ],
          ),
        ),
        
        // Comments List
        Expanded(
          child: catalogProvider.comments.isEmpty
              ? const Center(child: Text('No hay respuestas en este tema.', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: catalogProvider.comments.length,
                  itemBuilder: (context, index) {
                    final comment = catalogProvider.comments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.authorEmail ?? 'Usuario',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryLight),
                            ),
                            const SizedBox(height: 6),
                            Text(comment.content, style: const TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Add comment box
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una respuesta...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: _createComment,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
